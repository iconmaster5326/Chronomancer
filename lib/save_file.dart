import 'package:chronomancer/character.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';
import 'package:chronomancer/version.dart';
import 'package:convert/convert.dart';
import 'dart:typed_data';

class GMSParseResult {
  dynamic value;
  int length;

  GMSParseResult(this.value, this.length);
}

typedef GMSParseHandler = GMSParseResult Function(ByteData hexValues,
    [int offsetInBytes]);

class SaveFile {
  static const Map<int, GMSParseHandler> MAGIC_NUMBERS_TO_HANDLERS = {
    0x00000000: _parseDouble,
    0x01000000: _parseString,
    0x02000000: _parseList,
    0x0A000000: _parseInt,
    0x2F010000: _parseList,
    0x5B020000: _parseGrid,
    0x93010000: _parseMap,
  };

  static GMSParseResult _parseDouble(ByteData hexValues,
          [int offsetInBytes = 0]) =>
      GMSParseResult(
          hexValues.getFloat64(offsetInBytes + 4, Endian.little), 12);

  // FIXME: this should be 64-bit, but 64-bit int accessing not supported by dart2js
  static GMSParseResult _parseInt(ByteData hexValues,
          [int offsetInBytes = 0]) =>
      GMSParseResult(hexValues.getInt32(offsetInBytes + 4, Endian.little), 12);

  static GMSParseResult _parseString(ByteData hexValues,
      [int offsetInBytes = 0]) {
    var length = hexValues.getUint32(offsetInBytes + 4, Endian.little);
    return GMSParseResult(
        String.fromCharCodes(
            hexValues.buffer.asUint8List(offsetInBytes + 8, length)),
        8 + length);
  }

  static GMSParseResult _parseList(ByteData hexValues,
      [int offsetInBytes = 0]) {
    var length = hexValues.getUint32(offsetInBytes + 4, Endian.little);
    var totalContentsLength = 0;
    var result = [];
    for (var i = 0; i < length; i++) {
      var element = _parseSerializedGMS(
          hexValues, offsetInBytes + 8 + totalContentsLength);
      totalContentsLength += element.length;
      result.add(element.value);
    }
    return GMSParseResult(result, 8 + totalContentsLength);
  }

  static GMSParseResult _parseMap(ByteData hexValues, [int offsetInBytes = 0]) {
    var length = hexValues.getUint32(offsetInBytes + 4, Endian.little);
    var totalContentsLength = 0;
    var result = {};
    for (var i = 0; i < length; i++) {
      var key = _parseSerializedGMS(
          hexValues, offsetInBytes + 8 + totalContentsLength);
      totalContentsLength += key.length;

      var value = _parseSerializedGMS(
          hexValues, offsetInBytes + 8 + totalContentsLength);
      totalContentsLength += value.length;

      result[key.value] = value.value;
    }
    return GMSParseResult(result, 8 + totalContentsLength);
  }

  static GMSParseResult _parseGrid(ByteData hexValues,
      [int offsetInBytes = 0]) {
    var width = hexValues.getUint32(offsetInBytes + 4, Endian.little);
    var height = hexValues.getUint32(offsetInBytes + 8, Endian.little);
    var totalContentsLength = 0;
    var result = {};

    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        var element = _parseSerializedGMS(
            hexValues, offsetInBytes + 12 + totalContentsLength);

        totalContentsLength += element.length;
        result[Vector2(x, y)] = element.value;
      }
    }
    return GMSParseResult(result, 12 + totalContentsLength);
  }

  static GMSParseResult _parseSerializedGMS(ByteData hexValues,
      [int offsetInBytes = 0]) {
    var magicNumber = hexValues.getUint32(offsetInBytes, Endian.big);
    if (!MAGIC_NUMBERS_TO_HANDLERS.containsKey(magicNumber)) {
      throw Exception('unknown magic number: ${magicNumber.toRadixString(16)}');
    }
    return MAGIC_NUMBERS_TO_HANDLERS[magicNumber](hexValues, offsetInBytes);
  }

  static dynamic parseSerializedGMS(String hexString) => _parseSerializedGMS(
          ByteData.sublistView(Uint8List.fromList(hex.decode(hexString))))
      .value;

  static const SLOT_LOWER_BOUNDS = {
    0: 20001,
    1: 20010,
    2: 20100,
    3: 20110,
    4: 20120,
    5: 20020,
    6: 20030,
  };

  static const EQUIPMENT_SLOTS = [
    ItemType.HEAD,
    ItemType.BODY,
    ItemType.WEAPON,
    ItemType.ACCCESSORY,
    ItemType.AMULET,
    ItemType.RING,
    ItemType.FEET,
    ItemType.OFF_HAND,
  ];

  static const BASE_ENCHANT_KEYS = [
    'hp',
    'mp',
    'dmg',
    'attackspeed',
    'crit',
  ];

  static const GEM_SHAPES = [
    GemShape.SPHERE,
    GemShape.CUBE,
    GemShape.STAR,
  ];

  static Character fromJSON(Version version, dynamic j) {
    var generalInfo = (parseSerializedGMS(j['c']) as List);
    var classIndex = generalInfo[0];
    var level = generalInfo[1];
    var equipment = (parseSerializedGMS(j['e']) as Map)
        .map((key, value) => MapEntry(
            key,
            value is String && value.isNotEmpty
                ? parseSerializedGMS(value)
                : null))
        .entries
        .where((kv) => kv.key.y == 0)
        .map((kv) => kv.value)
        .toList();
    var skills = Map.fromEntries((parseSerializedGMS(j['sk']) as Map)
        .entries
        .where((kv) => kv.value > 0));
    var masteryChoices = (parseSerializedGMS(j['ms']) as Map);

    var result = Character(version.classWithIndex(classIndex));
    result.level = level;

    // skills
    for (var skillEntry in skills.entries) {
      var skillWithID = version.skills
          .firstWhere((s) => s.id == skillEntry.key, orElse: () => null);
      if (skillWithID == null) {
        print('warning: unknown skill ${skillEntry.key}');
        continue;
      }
      if (skillWithID.tallySkill) continue;
      Vector2 position;
      int slotIndex;
      if (skillWithID.tree == Character.MASTERY_TREE_ID) {
        for (var masteryChoice in masteryChoices.entries) {
          if (masteryChoice.value == skillWithID.id) {
            slotIndex = masteryChoice.key;
            for (var slotLowerBound in SLOT_LOWER_BOUNDS.entries) {
              var adjustedIndex = slotIndex - slotLowerBound.value;
              if (adjustedIndex >= 0 && adjustedIndex < 9) {
                position = Vector2(adjustedIndex + 2, slotLowerBound.key);
                break;
              }
            }
          }
        }
      } else {
        position = skillWithID.positions.first;
      }
      if (position == null) {
        print(
            'warning: could not find skill ${skillWithID.name} on the tree. slot index: ${slotIndex}');
        continue;
      }
      var spentSkill =
          SpentSkill(result, skillWithID.tree, position, skillWithID);
      spentSkill.rank = skillEntry.value;
      result.skills[skillWithID.tree][position] = spentSkill;
    }

    // equipment
    for (var i = 0; i < EQUIPMENT_SLOTS.length; i++) {
      var itemJSON = equipment[i];
      if (itemJSON == null) continue;
      var item = version.items
          .firstWhere((item) => item.id == itemJSON['id'], orElse: () => null);
      if (item == null) {
        print('warning: unknown skill ${itemJSON['id']}');
        continue;
      }

      var itemStack = ItemStack(item,
          rarity: ItemRarity.values[itemJSON['quality']],
          level: itemJSON['level']);
      if (itemJSON.containsKey('empowered')) {
        itemStack.empowered = itemJSON['empowered'] == 0 ? false : true;
      }

      // base enchants
      for (var i = 0; i < item.baseEnchants.length; i++) {
        var value = itemJSON[BASE_ENCHANT_KEYS[i]];
        if (i == 3) {
          // specific fixup for attack speed
          value *= 100;
        }
        itemStack.enchants[i].value = value as int;
      }

      // non-base enchants
      var enchantStacks = <EnchantStack>[];
      for (var enchantIndex = 0; enchantIndex <= 9; enchantIndex++) {
        var enchantID = itemJSON['enchant${enchantIndex}'];
        if (enchantID <= 0) continue;

        var enchantment = version.enchants
            .firstWhere((e) => e.id == enchantID, orElse: () => null);
        if (enchantment == null) {
          print(
              'warning: unknown enchantment ${enchantID} at index ${enchantIndex} on item ${item.name}');
          continue;
        }

        var source = EnchantStackSource.FLOATING;
        if (itemJSON['enchant_solid${enchantIndex}'] > 0) {
          source = EnchantStackSource.FIXED;
        }
        if (itemJSON['enchant_rune${enchantIndex}'] > 0) {
          source = EnchantStackSource.RUNE;
        }

        enchantStacks.add(EnchantStack(
            source, enchantment, itemJSON['enchant_value${enchantIndex}']));
      }
      var enchantSlotsFilled = <int>{};
      for (var enchant in enchantStacks) {
        var found = false;
        for (var i = 0; i < itemStack.enchants.length; i++) {
          if (!enchantSlotsFilled.contains(i) &&
              itemStack.sourceOf(i) == enchant.source &&
              itemStack.enchantTypesForSlot(i).contains(enchant.type)) {
            enchantSlotsFilled.add(i);
            itemStack.enchants[i] = enchant;
            found = true;
            break;
          }
        }
        if (!found) {
          print(
              'warning: enchant ${enchant.name} (of type ${enchant.type} and source ${enchant.source}) could not be placed in item ${item.name}');
        }
      }

      // gems
      itemStack.gems.clear();
      var lastNonprisGemIndex;
      for (var gemIndex = 0; gemIndex <= 5; gemIndex++) {
        if (itemJSON['socket_type${gemIndex}'] < 0) break;
        if (itemJSON['socket_prismatic${gemIndex}'] != 0) break;
        lastNonprisGemIndex= gemIndex;
      }
      for (var gemIndex = 0; gemIndex <= 5; gemIndex++) {
        var gemTypeIndex = itemJSON['socket_type${gemIndex}'];
        if (gemTypeIndex < 0) continue;
        print(
            "item ${item.name} socket ${gemIndex} has type ${itemJSON['socket_type${gemIndex}']} gem ${itemJSON['socket_gem${gemIndex}']} val ${itemJSON['socket_val${gemIndex}']} prismatic ${itemJSON['socket_prismatic${gemIndex}']}");
        var source = GemSource.INNATE;
        if (itemJSON['socket_prismatic${gemIndex}'] != 0) {
          source = GemSource.PRISMATIC;
        } else if (item.id == ItemStack.WEYRICKS_FINERY_ID && lastNonprisGemIndex - gemIndex < 3) {
          source = GemSource.ENCHANT;
        } else if (item.id == ItemStack.RING_OF_MARVELLOUS_GEMS_ID && lastNonprisGemIndex - gemIndex < 2) {
          source = GemSource.ENCHANT;
        }
        var socket = GemSocket(itemStack, source, GEM_SHAPES[gemTypeIndex]);
        var gemID = itemJSON['socket_gem${gemIndex}'];
        if (gemID > 0) {
          socket.gem =
              version.gems.firstWhere((g) => g.id == gemID, orElse: () => null);
          if (socket.gem == null) {
            print(
                'warning: unknown gem ID ${gemID} in socket ${gemIndex} in item ${item.name}');
          }
        }
        itemStack.gems.add(socket);
      }

      var slot = EQUIPMENT_SLOTS[i];
      result.equipment[slot] = itemStack;
    }

    return result;
  }
}
