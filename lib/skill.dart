import 'dart:convert';

import 'package:chronomancer/character.dart';
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
  'Ritual Skill': SkillType.AURA,
  'Perk': SkillType.PERK,
};

enum SkillElement {
  ETHEREAL,
  PHYSICAL,
  FIRE,
  LIGHTNING,
  FROST,
  POISON,
  HOLY,
  SHADOW,
}

const ELEMENT_TO_STRING = {
  SkillElement.ETHEREAL: 'Ethereal',
  SkillElement.PHYSICAL: 'Physical',
  SkillElement.FIRE: 'Fire',
  SkillElement.LIGHTNING: 'Lightning',
  SkillElement.FROST: 'Frost',
  SkillElement.POISON: 'Poison',
  SkillElement.HOLY: 'Holy',
  SkillElement.SHADOW: 'Shadow',
};

class Skill {
  static const TREE_MASTERY = 4;
  static const X_TO_MIN_LEVEL = <int, int>{
    2: 0,
    3: 4,
    4: 9,
    5: 14,
    6: 19,
    7: 24,
    8: 29,
    9: 34,
  };

  Version version;
  int id, tree, maxRank, minLevel, manaCostMinLevel, manaCostMaxLevel, cooldown;
  String name, typeName, desc, rankUpDesc;
  CharClass charClass;
  SkillType type;
  List<Skill> requires;
  List<Vector2> positions;
  bool tallySkill;
  SkillElement element;
  Map<String, List<String>> descVariableValues;
  List<String> tags;

  int _x, _y;
  String _rawClass, _rawTree;
  List<int> _rawRequires;

  static const DESC_VARIABLES = [
    'effect',
    'damage',
    'range2',
    'range',
    'value',
    'proc',
    'duration',
  ];

  Skill.fromJSON(this.version, Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        typeName = j['type'] ?? 'Perk',
        type = STRING_TO_SKILL_TYPE[j['type'] ?? 'Perk'],
        desc = j['description'],
        rankUpDesc = j['description_next'],
        tallySkill = (j['x'] == 0),
        minLevel = j['minLevel'],
        maxRank = j['maxRank'],
        element = ELEMENT_TO_STRING.inverted[j['element']],
        descVariableValues = Map.fromEntries(DESC_VARIABLES
            .map((k) => MapEntry(k, j[k] as List))
            .where((e) => e.value != null)
            .map((e) =>
                MapEntry(e.key, e.value.map((v) => v.toString()).toList()))),
        tags = j.containsKey('family') ? [j['family']] : [],
        manaCostMinLevel = j['cost'],
        manaCostMaxLevel = j['cost100'],
        _x = j['x'],
        _y = j['y'],
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
    } else if (tree == TREE_MASTERY &&
        _x == 10 &&
        _y == 0 &&
        element == SkillElement.ETHEREAL) {
      // Mastery generic rightmost skills can be in four positions
      positions = [
        Vector2(10, 0),
        Vector2(10, 1),
        Vector2(10, 5),
        Vector2(10, 6)
      ];
    } else if (tree == TREE_MASTERY && _y == 2 && _x.between(2, 9)) {
      // mastery tree center skills can be in three positions
      positions = [Vector2(_x, _y), Vector2(_x, _y + 1), Vector2(_x, _y + 2)];
    } else if (tree == TREE_MASTERY &&
        _x == 2 &&
        _y == 0 &&
        charClass.masteryCol2FloatIDs.contains(id)) {
      // Some mastery leftmost skills can be in four positions
      positions = [Vector2(2, 0), Vector2(2, 1), Vector2(2, 5), Vector2(2, 6)];
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

    // fix up minLevel
    if (tree != TREE_MASTERY) {
      minLevel = X_TO_MIN_LEVEL[_x] ?? 0;
    }
  }

  static Future<List<Skill>> getSkillList(Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/skills.json');
    return (json.decode(response.body) as List)
        .map((j) => Skill.fromJSON(version, j))
        .toList();
  }

  Iterable<Skill> get unlocks =>
      version.skills.where((s) => s.requires.contains(this));
  Iterable<Skill> get recursivelyUnlocks =>
      unlocks.followedBy(unlocks.map((s) => s.recursivelyUnlocks).flatten);
  String get elementName => ELEMENT_TO_STRING[element];

  List<Skill> _modifierOf;
  List<Skill> get modifierOf => _modifierOf ??= version.skills
      .where((s) =>
          s.tree == tree &&
          s.requires.isEmpty &&
          s.recursivelyUnlocks.contains(this))
      .toList();

  int manaCost(int atLevel) {
    if (manaCostMinLevel == null || manaCostMaxLevel == null) return null;
    return manaCostMinLevel +
        (((manaCostMaxLevel - manaCostMinLevel) / Character.MAX_LEVEL) *
                atLevel)
            .round();
  }
}
