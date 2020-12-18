import 'dart:convert';
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

class Enchant {
  int id;
  String name, desc;
  EnchantType type;

  Enchant(this.id, this.name, this.desc, this.type);

  Enchant.fromJSON(Map<String, dynamic> j)
      : this(j['uuid'], j['name'], j['description'],
            ENCHANT_TYPE_TO_STRING.inverted[j['type']]);

  static Future<List<Enchant>> getEnchantList(
      Version version, Client http) async {
    final response =
        await http.get('assets/json/${version.name}/enchants.json');
    return (json.decode(response.body) as List)
        .map((j) => Enchant.fromJSON(j))
        .toList();
  }
}
