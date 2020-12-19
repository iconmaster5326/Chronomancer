import 'dart:convert';

import 'package:http/http.dart';

import 'class.dart';
import 'util.dart';
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
  static const int TREE_MASTERY = 4;

  int id, tree, maxRank;
  String name, typeName, desc;
  CharClass charClass;
  SkillType type;
  List<Skill> requires;
  List<Vector2> positions;
  bool tallySkill;

  int _x, _y;
  String _rawClass, _rawTree;
  List<int> _rawRequires;

  Skill.fromJSON(Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        typeName = j['type'] ?? 'Perk',
        type = STRING_TO_SKILL_TYPE[j['type'] ?? 'Perk'],
        desc = j['description'],
        tallySkill = (j['x'] == 0),
        _x = j['x'],
        _y = j['y'],
        maxRank = j['maxRank'],
        _rawClass = j['class'],
        _rawTree = j['tree'],
        _rawRequires = List<int>.from(j['skillRequirement']);

  void finalize(Version version) {
    // link up data
    charClass = version.classWithName(_rawClass);
    tree = charClass.skillTrees.indexOf(_rawTree);
    requires = _rawRequires
        .map((id) =>
            version.skills.firstWhere((s) => s.id == id, orElse: () => null))
        .where((s) => s != null)
        .toList();

    // save space, delete raw data
    _rawClass = null;
    _rawTree = null;
    _rawRequires = null;

    // calculate positions
    if (id == 0) {
      // the None skill is not on the tree
      positions = [];
    } else if (tree == TREE_MASTERY && _y == 2 && _x.between(2, 9)) {
      // mastery tree center skills can be in three positions
      positions = [Vector2(_x, _y), Vector2(_x, _y + 1), Vector2(_x, _y + 2)];
    } else {
      positions = [Vector2(_x, _y)];
    }

    // fix up type and typeName
    if (tree == TREE_MASTERY) {
      var isPerk = false;

      if (_y.between(2, 4)) {
        if ([4, 7, 10].contains(_x)) {
          isPerk = true;
        }
      } else {
        if ([4, 6, 8, 10].contains(_x)) {
          isPerk = true;
        }
      }

      if (isPerk) {
        type = SkillType.PERK;
        typeName = 'Perk';
      } else {
        type = SkillType.PASSIVE;
        typeName = 'Passive Skill';
      }
    }
  }

  static Future<List<Skill>> getSkillList(Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/skills.json');
    return (json.decode(response.body) as List)
        .map((j) => Skill.fromJSON(j))
        .toList();
  }
}