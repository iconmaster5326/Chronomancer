import 'dart:convert';

import 'package:http/http.dart';

import 'class.dart';
import 'version.dart';

enum SkillType {
  ACTIVE,
  AURA,
  PASSIVE,
  PERK,
}

const Map<String, SkillType> STRING_TO_SKILL_TYPE = <String, SkillType>{
  'Active Skill': SkillType.ACTIVE,
  'Ultimate Skill': SkillType.ACTIVE,
  'Passive Skill': SkillType.PASSIVE,
  'Aura Skill': SkillType.AURA,
  'Heritage Skill': SkillType.AURA,
  'Companion Skill': SkillType.AURA,
  'Perk': SkillType.PERK,
};

class Skill {
  int id, tree, x, y, maxRank;
  String name, typeName, desc;
  CharClass charClass;
  SkillType type;
  List<Skill> requires;

  String _rawClass, _rawTree;
  List<int> _rawRequires;

  Skill.fromJSON(Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        typeName = j['type'] ?? 'Perk',
        type = STRING_TO_SKILL_TYPE[j['type'] ?? 'Perk'],
        desc = j['description'],
        x = j['x'],
        y = j['y'],
        maxRank = j['maxRank'],
        _rawClass = j['class'],
        _rawTree = j['tree'],
        _rawRequires = List<int>.from(j['skillRequirement']);

  void finalize(Version version) {
    charClass = version.classWithName(_rawClass);
    tree = charClass.skillTrees.indexOf(_rawTree);
    requires = _rawRequires
        .map((id) => version.skills.firstWhere((s) => s.id == id, orElse: () => null))
        .where((s) => s != null)
        .toList();

    _rawClass = null;
    _rawTree = null;
    _rawRequires = null;
  }

  static Future<List<Skill>> getSkillList(Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/skills.json');
    return (json.decode(response.body) as List)
        .map((j) => Skill.fromJSON(j))
        .toList();
  }
}
