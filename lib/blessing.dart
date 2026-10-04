import 'dart:convert';
import 'package:http/http.dart';

import 'class.dart';
import 'item.dart';
import 'version.dart';

const Map<String, ItemType> BLESSING_SLOT_TO_ITEM_TYPE = <String, ItemType>{
  'Helm': ItemType.HEAD,
  'Armor': ItemType.BODY,
  'Weapon': ItemType.WEAPON,
  'Accessory': ItemType.ACCCESSORY,
  'Amulet': ItemType.AMULET,
  'Ring': ItemType.RING,
  'Boots': ItemType.FEET,
  'Offhand': ItemType.OFF_HAND,
};

/// Only versions from 1.60.0 onwards have blessings and curses.
bool _hasBlessings(Version version) {
  var parts = version.name.split('.').map(int.parse).toList();
  return parts[0] > 1 || (parts[0] == 1 && parts[1] >= 60);
}

Future<List> _getOptionalList(
    Version version, Client http, String filename) async {
  if (!_hasBlessings(version)) return [];
  final response = await http.get('assets/json/${version.name}/$filename.json');
  if (response.statusCode != 200) return [];
  return json.decode(response.body) as List;
}

class Blessing {
  int id;
  String name, desc;
  ItemType slot;
  List<CharClass> classes;

  Blessing.fromJSON(Version version, Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        desc = (j['description'] as String)
            .replaceAll('AMOUNT', j['value'].toString()),
        slot = BLESSING_SLOT_TO_ITEM_TYPE[j['slot']],
        classes = List<String>.from(j['classes'])
            .map((name) => version.classWithName(name))
            .where((c) => c != null)
            .toList();

  bool canBeOn(ItemData item, CharClass charClass) =>
      slot == item.type && classes.contains(charClass);

  static Future<List<Blessing>> getBlessingList(
          Version version, Client http) async =>
      (await _getOptionalList(version, http, 'blessings'))
          .map((j) => Blessing.fromJSON(version, j))
          .toList();
}

class Curse {
  int id;
  String name, desc, purifyDesc;
  List<ItemType> slots;
  bool shieldOnly;

  Curse.fromJSON(Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        desc = (j['description'] as String)
            .replaceAll('NUM', j['value']?.toString() ?? ''),
        purifyDesc = (j['purifyAction'] as String)
            .replaceAll('MAX', j['purifyRequired'].toString()),
        slots = List<String>.from(j['slots'])
            .map((s) => BLESSING_SLOT_TO_ITEM_TYPE[s])
            .toList(),
        shieldOnly = j['shieldOnly'];

  bool canBeOn(ItemData item) =>
      slots.contains(item.type) && (!shieldOnly || item.typeName == 'Shield');

  static Future<List<Curse>> getCurseList(Version version, Client http) async =>
      (await _getOptionalList(version, http, 'curses'))
          .map((j) => Curse.fromJSON(j))
          .toList();
}
