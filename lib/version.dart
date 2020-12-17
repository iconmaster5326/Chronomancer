import 'dart:convert';
import 'package:http/http.dart';

import 'class.dart';

class Version {
  String name;
  List<CharClass> classes;

  Version(this.name, this.classes);

  static Future<Version> fromName(Client http, String name) async =>
      Version(name, await CharClass.getClassList(name, http));

  static Future<List<Version>> getVersions(Client http) async {
    final response = await http.get('assets/json/patches.json');
    return Stream.fromIterable(json.decode(response.body) as List)
        .asyncMap((v) => Version.fromName(http, v))
        .toList();
  }
}
