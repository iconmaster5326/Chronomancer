import 'dart:convert';

import 'package:http/http.dart';

import 'item.dart';
import 'version.dart';

class ItemSet {
  String id, name;
  List<Item> items;
  Map<int, String> desc;
  List<int> _rawItems;

  ItemSet.fromJSON(Map j)
      : id = j['uuid'],
        name = j['name'],
        desc = (j['bonuses'] as Map)
            .map((k, v) => MapEntry<int, String>(int.parse(k), v)),
        _rawItems = List<int>.from(j['itemIds']);

  void finalize(Version version) {
    items = _rawItems
        .map((i) => version.items.firstWhere((item) => item.id == i))
        .toList();
    for (var item in items) {
      item.partOfSet = this;
    }
    _rawItems = null;
  }

  static Future<List<ItemSet>> getSetList(Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/sets.json');
    return (json.decode(response.body) as List)
        .map((j) => ItemSet.fromJSON(j))
        .toList();
  }
}
