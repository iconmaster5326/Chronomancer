import 'dart:convert';

import 'package:http/http.dart';

import 'enchant.dart';
import 'item.dart';
import 'version.dart';

enum GemShape {
  CUBE,
  SPHERE,
  STAR,
}

enum GemQuality {
  ROUGH,
  CUT,
  POLISHED,
}

class Gem {
  Version version;
  int id;
  String name;
  GemShape shape;
  GemQuality quality;
  Map<ItemType, Enchant> enchants = {};
  List<int> _rawEnchants;

  static const _TYPE_TO_SHAPE = {
    'Cube Gem': GemShape.CUBE,
    'Sphere Gem': GemShape.SPHERE,
    'Star Gem': GemShape.STAR,
  };

  static const _RARITY_TO_QUALITY = {
    'Ordinary': GemQuality.ROUGH,
    'Enchanted': GemQuality.CUT,
    'Rare': GemQuality.POLISHED,
  };

  Gem.fromJSON(this.version, Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        shape = _TYPE_TO_SHAPE[j['type']],
        quality = _RARITY_TO_QUALITY[j['rarity']],
        _rawEnchants = List<int>.from(j['fixedEnchants']);

  void finalize(Version version) {
    enchants[ItemType.WEAPON] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[0]);
    enchants[ItemType.OFF_HAND] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[0]);
    enchants[ItemType.HEAD] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[1]);
    enchants[ItemType.BODY] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[1]);
    enchants[ItemType.FEET] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[1]);
    enchants[ItemType.AMULET] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[2]);
    enchants[ItemType.RING] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[2]);
    enchants[ItemType.ACCCESSORY] =
        version.enchants.firstWhere((e) => e.id == _rawEnchants[2]);
    _rawEnchants = null;
  }

  static Future<List<Gem>> getGemList(Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/items.json');
    return (json.decode(response.body) as List)
        .where((j) => j['category'] == 'Gem' && j['fixedEnchants'].length == 3)
        .map((j) => Gem.fromJSON(version, j))
        .toList();
  }
}
