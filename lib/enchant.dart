import 'dart:convert';
import 'package:chronomancer/item.dart';
import 'package:http/http.dart';

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
      var range = EnchantRange(entry.value['minimum'], entry.value['maximum'],
          entry.value['cap'], entry.value['greaterCap']);
      ranges[rarity] = range;
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
