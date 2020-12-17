import 'dart:convert';
import 'package:http/http.dart';

class CharClass {
  String id, name;
  List<String> skillTrees;

  CharClass(this.id, this.name, this.skillTrees);

  static CharClass fromJSON(Map<String, dynamic> j) =>
      CharClass(j['uuid'], j['name'], List<String>.from(j['skillTrees']));

  static Future<List<CharClass>> getClassList(
      String versionName, Client http) async {
    final response = await http.get('assets/json/$versionName/classes.json');
    return (json.decode(response.body) as List)
        .map((j) => CharClass.fromJSON(j))
        .toList();
  }
}
