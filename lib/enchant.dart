import 'dart:convert';
import 'package:chronomancer/item.dart';
import 'package:http/http.dart';

import 'class.dart';
import 'util.dart';
import 'version.dart';

enum EnchantType {
  GEM,
  MINOR,
  MAJOR,
  EPIC,
  LEGENDARY,
}

const Map<EnchantType, String> ENCHANT_TYPE_TO_STRING = <EnchantType, String>{
  EnchantType.GEM: 'Gem',
  EnchantType.MINOR: 'Minor',
  EnchantType.MAJOR: 'Major',
  EnchantType.EPIC: 'Epic',
  EnchantType.LEGENDARY: 'Legendary',
};

class EnchantRange {
  int min, max, maxAugmented, maxGreaterAugmented;

  EnchantRange(this.min, this.max, this.maxAugmented, this.maxGreaterAugmented);
}

class Rune {
  List<ItemType> usableOn;
  bool greater;
  CharClass classRequires;

  Rune(this.usableOn, this.greater, this.classRequires);
}

abstract class EnchantData {
  String get name;
  String get desc;
  EnchantStackSource get source;
  int get value;
  Map<ItemRarity, EnchantRange> get ranges;
  EnchantType get type => null;
}

class Enchant implements EnchantData {
  static const int GREATNESS_ID = 1296;

  int id;
  @override
  String name;
  @override
  String desc;
  @override
  EnchantType type;
  @override
  Map<ItemRarity, EnchantRange> ranges = {};
  Rune rune;

  @override
  EnchantStackSource get source => EnchantStackSource.FLOATING;
  @override
  int get value => null;

  List<int> _rawItems;

  Enchant.fromJSON(Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        desc = j['description'],
        type = ENCHANT_TYPE_TO_STRING.inverted[j['type']] {
    for (var entry in (j['ranges'] as Map).entries) {
      var rarity = ITEM_RARITY_TO_STRING.inverted[entry.key];
      if (rarity != null) {
        var range = EnchantRange(entry.value['minimum'], entry.value['maximum'],
            entry.value['cap'], entry.value['greaterCap']);
        ranges[rarity] = range;
      }
    }

    if (type == EnchantType.LEGENDARY) {
      _rawItems = List<int>.from(j['items']);
    }
  }

  void finalize(Version version) {
    if (type == EnchantType.LEGENDARY) {
      if (_rawItems.isEmpty) {
        // dropped rune
        Map data = version.rawDroppedRuneData
            .firstWhere((m) => m['uuid'] == id, orElse: () => null);
        if (data != null) {
          rune = Rune(
              List<String>.from(data['categories'])
                  .map((c) => ITEM_TYPE_TO_STRING.inverted[c])
                  .toList(),
              false,
              version.classWithName(data['class']));
        } else {
          print(
              'warning: could not find dropped rune data for skill with id $id in version ${version.name}');
        }
      } else {
        // rune from equipment
        var item = version.items.firstWhere((i) => i.id == _rawItems.first);
        rune = Rune([item.type], item.rarity == ItemRarity.TRUE_LEGENDARY,
            item.requiresClass);
      }

      _rawItems = null;
    }
  }

  static Future<List<Enchant>> getEnchantList(
      Version version, Client http) async {
    final response =
        await http.get('assets/json/${version.name}/enchants.json');
    return (json.decode(response.body) as List)
        .map((j) => Enchant.fromJSON(j))
        .toList();
  }

  static Future<List> getRawDroppedRuneData(
      Version version, Client http) async {
    final response =
        await http.get('assets/json/${version.name}/droppedRunes.json');
    return json.decode(response.body);
  }

  static Future<Map<CharClass, Map<ItemType, Map<EnchantType, List<Enchant>>>>>
      getEnchantPool(Version version, Client http) async {
    var j = Map.from(json.decode(
        (await http.get('assets/json/${version.name}/enchantsPool.json'))
            .body));

    var result = <CharClass, Map<ItemType, Map<EnchantType, List<Enchant>>>>{};
    for (var charClass in version.classes) {
      var typeToString = ITEM_TYPE_TO_STRING.inverted;
      for (var name in charClass.weaponNames) {
        typeToString[name] = ItemType.WEAPON;
      }
      for (var name in charClass.offhandNames) {
        typeToString[name] = ItemType.OFF_HAND;
      }

      result[charClass] = {};
      for (var entry in j.entries) {
        var slot = typeToString[entry.key];
        result[charClass][slot] = {};
        for (var entry2 in entry.value.entries) {
          var type = ENCHANT_TYPE_TO_STRING.inverted[entry2.key];
          result[charClass][slot][type] = List<int>.from(entry2.value)
              .map((i) => version.enchants.firstWhere((e) => e.id == i))
              .toList();
        }
      }
    }
    return result;
  }

  String get searchText => [name, desc].join('\n').toLowerCase();
}

enum EnchantStackSource {
  BASE,
  FIXED,
  RUNE,
  FLOATING,
}

class EnchantStack implements EnchantData {
  @override
  EnchantStackSource source;
  Enchant enchant;
  @override
  int value;

  EnchantStack(this.source, this.enchant, this.value);

  int get id => enchant.id;
  @override
  String get name => enchant.name;
  @override
  String get desc => enchant.desc;
  @override
  EnchantType get type => enchant.type;
  @override
  Map<ItemRarity, EnchantRange> get ranges => enchant.ranges;

  dynamic get asJSON => {
        'id': id,
        'value': value,
      };

  EnchantStack.fromJSON(Version version, dynamic j)
      : enchant = version.enchants.firstWhere((x) => x.id == j['id']),
        value = j['value'];
}
