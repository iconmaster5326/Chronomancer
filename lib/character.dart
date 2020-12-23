import 'package:chronomancer/class.dart';

import 'enchant.dart';
import 'item.dart';
import 'skill.dart';
import 'util.dart';
import 'set.dart';
import 'version.dart';

class SpentSkill {
  Character character;
  int tree;
  Vector2 pos;
  int rank = 0;
  Skill skill;

  SpentSkill(this.character, this.tree, this.pos, this.skill);

  bool get unlocked => character.skillUnlocked(skill);

  bool get canRankUp {
    if (!unlocked) return false;
    if (rank == skill.maxRank) return false;
    if (tree != Skill.TREE_MASTERY &&
        character.pointsSpent >= character.level) {
      return false;
    }
    return true;
  }

  Iterable<SpentSkill> get _masterySpentSkillsAfter {
    var result = Range(pos.x + 1, 10)
        .map((x) => character.skills[tree][Vector2(x, pos.y)]);

    if (pos.y == 3 || pos.y == 4) {
      return result.followedBy([character.skills[tree][Vector2(10, 3)]]);
    } else {
      return result;
    }
  }

  bool get canRankDown {
    if (!unlocked || rank == 0) return false;

    if (tree == Skill.TREE_MASTERY) {
      if (!_masterySpentSkillsAfter.every((spentSkill) =>
          spentSkill == null ||
          spentSkill.rank == 0 ||
          spentSkill.skill.minLevel <
              Range(2, spentSkill.pos.x - 1)
                  .map((x) =>
                      character.skills[tree][Vector2(x, pos.y)]?.rank ?? 0)
                  .sum)) {
        return false;
      }

      if (rank == 1 &&
          _masterySpentSkillsAfter
              .any((spentSkill) => spentSkill != null && spentSkill.rank > 0)) {
        return false;
      }
    } else {
      if (!character.skills[tree].values
          .where(
              (spentSkill) => spentSkill.pos.x > pos.x && spentSkill.rank != 0)
          .every((spentSkill) =>
              spentSkill.skill.minLevel <
              Range(2, spentSkill.pos.x - 1)
                  .map((i) => character.pointsSpentInCol(tree, i))
                  .sum)) {
        return false;
      }

      if (rank == 1 &&
          skill.recursivelyUnlocks
              .map((skill) => skill.positions
                  .map((pos) => character.skills[skill.tree][pos]))
              .flatten
              .any((spentSkill) => spentSkill != null && spentSkill.rank > 0)) {
        return false;
      }
    }

    return true;
  }

  dynamic get asJSON => {
        'x': pos.x,
        'y': pos.y,
        'id': skill.id,
        'rank': rank,
      };

  SpentSkill.fromJSON(this.character, dynamic j)
      : skill = character.charClass.version.skills.firstWhere((x) => x.id == j['id']),
        pos = Vector2(j['x'], j['y']),
        rank = j['rank'] {
    tree = skill.tree;
  }
}

class Character {
  static const int MAX_LEVEL = 100;

  CharClass charClass;
  Map<ItemType, ItemStack> equipment = <ItemType, ItemStack>{};
  int level = MAX_LEVEL;
  List<Map<Vector2, SpentSkill>> skills;

  Character(this.charClass) {
    skills = List.generate(charClass.skillTrees.length, (_) => {});
  }

  int get pointsSpent =>
      List<int>.generate(skills.length - 1, (i) => pointsSpentIn(i))
          .fold(0, (sum, n) => sum + n);
  int get masteryPointsSpent => pointsSpentIn(Skill.TREE_MASTERY);
  int get greaterRunes => equipment.values
      .where((item) =>
          item.enchants[item.runeEnchantSlot] != null &&
          item.enchants[item.runeEnchantSlot].enchant.rune.greater)
      .length;
  int get maxGreaterRunes => equipment.values.any((item) =>
          item != null &&
          item.enchants
              .any((e) => e != null && e.enchant.id == Enchant.GREATNESS_ID))
      ? 4
      : 3;

  int pointsSpentIn(int tree) =>
      skills[tree].values.fold(0, (sum, spentSkill) => sum + spentSkill.rank);
  int pointsSpentInCol(int tree, int col) => skills[tree]
      .values
      .where((spentSkill) => spentSkill.pos.x == col)
      .fold(0, (sum, spentSkill) => sum + spentSkill.rank);
  int pointsSpentInRow(int tree, int row) => skills[tree]
      .values
      .where((spentSkill) => spentSkill.pos.y == row)
      .fold(0, (sum, spentSkill) => sum + spentSkill.rank);

  bool skillUnlocked(Skill skill) {
    if (skill.tree == Skill.TREE_MASTERY) {
      if (skill.positions.first.x <= 2) {
        return true;
      }

      var spentSkill = findSpentSkill(skill);
      if (spentSkill == null) {
        return false;
      }

      var rowsRequired = [spentSkill.pos.y];
      if (spentSkill.pos == Vector2(10, 3)) {
        rowsRequired.addAll([spentSkill.pos.y - 1, spentSkill.pos.y + 1]);
      }

      for (var y in rowsRequired) {
        if (pointsSpentInRow(skill.tree, y) < skill.minLevel) {
          return false;
        }

        if (Range(2, spentSkill.pos.x - 1)
            .map((x) => skills[skill.tree][Vector2(x, y)])
            .any((spentSkill) => spentSkill == null || spentSkill.rank < 1)) {
          return false;
        }
      }

      return true;
    } else {
      return pointsSpentIn(skill.tree) >= skill.minLevel &&
          (skill.requires.isEmpty ||
              skill.requires.any((requirement) {
                var spentSkill =
                    skills[requirement.tree][requirement.positions.first];
                if (spentSkill == null) {
                  return false;
                }
                return spentSkill.rank > 0;
              }));
    }
  }

  SpentSkill findSpentSkill(Skill skill) {
    return skill.positions.map((pos) => skills[skill.tree][pos]).firstWhere(
        (spentSkill) => spentSkill != null && spentSkill.skill == skill,
        orElse: () => null);
  }

  Skill modifierOf(Skill skill) => skill.modifierOf.firstWhere(
      (s) => skills[skill.tree].values.any((ss) => ss.skill == s),
      orElse: () => null);

  int itemSetMembersEquipped(ItemSet itemSet) =>
      equipment.values.where((i) => i != null && i.partOfSet == itemSet).length;

  dynamic get asJSON => {
        'version': charClass.version.name,
        'class': charClass.id,
        'level': level,
        'skills': skills
            .map((spentSkills) => spentSkills.values.map((x) => x?.asJSON))
            .flatten,
        'items':
            equipment.map((k, v) => MapEntry(k.index.toString(), v?.asJSON)),
      };

  Character.fromJSON(Iterable<Version> versions, dynamic j) {
    var version = versions.firstWhere((x) => x.name == j['version']);
    charClass = version.classes.firstWhere((x) => x.id == j['class']);
    level = j['level'];

    skills = List.generate(charClass.skillTrees.length, (_) => {});
    for (var spentSkillJSON in j['skills']) {
      var spentSkill = SpentSkill.fromJSON(this, spentSkillJSON);
      skills[spentSkill.tree][spentSkill.pos] = spentSkill;
    }

    for (var itemJSON in j['items'].entries) {
      equipment[ItemType.values[int.parse(itemJSON.key)]] =
          ItemStack.fromJSON(version, itemJSON.value);
    }
  }
}
