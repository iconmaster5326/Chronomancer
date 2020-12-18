import 'dart:convert';
import 'package:http/http.dart';

import 'class.dart';
import 'item.dart';

class Version {
  String name;
  List<CharClass> classes;
  List<Item> items;

  Version(this.name);

  static Future<Version> fromName(Client http, String name) async {
      var version = Version(name);
      version.classes = await CharClass.getClassList(version, http);
      version.items = await Item.getItemList(version, http);
      return version;
  }

  static Future<List<Version>> getVersions(Client http) async {
    final response = await http.get('assets/json/patches.json');
    return Stream.fromIterable(json.decode(response.body) as List)
        .asyncMap((v) => Version.fromName(http, v))
        .toList();
  }

  CharClass classWithName(String name) {
    for (var charClass in classes) {
      if (charClass.name == name) {
        return charClass;
      }
    }
    return null;
  }
}
