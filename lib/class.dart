import 'dart:convert';
import 'package:http/http.dart';

import 'version.dart';

class CharClass {
  Version version;
  String id, name;
  List<String> skillTrees, weaponNames, offhandNames;
  List<int> masteryCol2FloatIDs;

  CharClass(this.version, this.id, this.name, this.skillTrees, this.weaponNames,
      this.offhandNames, this.masteryCol2FloatIDs);

  CharClass.fromJSON(Version version, Map<String, dynamic> j)
      : this(
            version,
            j['uuid'],
            j['name'],
            List<String>.from(j['skillTrees']),
            List<String>.from(j['weaponNames']),
            List<String>.from(j['offhandNames']),
            List<int>.from(j['masteryCol2Floats']));

  static Future<List<CharClass>> getClassList(
      Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/classes.json');
    return (json.decode(response.body) as List)
        .map((j) => CharClass.fromJSON(version, j))
        .toList();
  }

  int maxPointsInTree(int tree) => version.skills
      .firstWhere((s) => s.charClass == this && s.tree == tree && s.tallySkill)
      .maxRank;
}
