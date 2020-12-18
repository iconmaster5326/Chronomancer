import 'dart:convert';
import 'package:http/http.dart';

import 'version.dart';

class CharClass {
  String id, name;
  List<String> skillTrees;

  CharClass(this.id, this.name, this.skillTrees);

  CharClass.fromJSON(Map<String, dynamic> j)
      : this(j['uuid'], j['name'], List<String>.from(j['skillTrees']));

  static Future<List<CharClass>> getClassList(
      Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/classes.json');
    return (json.decode(response.body) as List)
        .map((j) => CharClass.fromJSON(j))
        .toList();
  }
}
