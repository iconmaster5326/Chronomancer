import 'package:chronomancer/class.dart';

import 'item.dart';
import 'skill.dart';
import 'util.dart';

class SpentSkill {
  Character character;
  int tree;
  Vector2 pos;
  int rank = 0;
  Skill skill;

  SpentSkill(this.character, this.tree, this.pos, this.skill);

  bool get unlocked => character.skillUnlocked(skill);
  bool get canRankUp =>
      unlocked &&
      rank != skill.maxRank &&
      character.pointsSpent < character.level;
  bool get canRankDown {
    if (!unlocked || rank == 0) {
      return false;
    }

    if (!character.skills[tree].values
        .where((spentSkill) => spentSkill.pos.x > pos.x && spentSkill.rank != 0)
        .every((spentSkill) =>
            spentSkill.skill.minLevel <
            Range(2, spentSkill.pos.x-1)
                .map((i) => character.pointsSpentInTier(tree, i))
                .sum)) {
      return false;
    }

    if (rank == 1 &&
        skill.recursivelyUnlocks
            .map((skill) =>
                skill.positions.map((pos) => character.skills[skill.tree][pos]))
            .flatten
            .any((spentSkill) => spentSkill != null && spentSkill.rank > 0)) {
      return false;
    }

    return true;
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

  int pointsSpentIn(int tree) =>
      skills[tree].values.fold(0, (sum, spentSkill) => sum + spentSkill.rank);
  int pointsSpentInTier(int tree, int tier) => skills[tree]
      .values
      .where((spentSkill) => spentSkill.pos.x == tier)
      .fold(0, (sum, spentSkill) => sum + spentSkill.rank);

  bool skillUnlocked(Skill skill) =>
      pointsSpentIn(skill.tree) >= skill.minLevel &&
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
