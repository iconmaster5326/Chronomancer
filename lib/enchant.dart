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

class Enchant {
  int id;
  String name, desc;
  EnchantType type;
  Map<ItemRarity, EnchantRange> ranges = {};

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
  }

  static Future<List<Enchant>> getEnchantList(
      Version version, Client http) async {
    final response =
        await http.get('assets/json/${version.name}/enchants.json');
    return (json.decode(response.body) as List)
        .map((j) => Enchant.fromJSON(j))
        .toList();
  }

  static Future<Map<CharClass, Map<ItemType, Map<EnchantType, List<Enchant>>>>> getEnchantPool(
      Version version, Client http) async {
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
}

class EnchantStack {
  Enchant enchant;
  int value;

  EnchantStack(this.enchant, this.value);

  int get id => enchant.id;
  String get name => enchant.name;
  String get desc => enchant.desc;
  EnchantType get type => enchant.type;
}
