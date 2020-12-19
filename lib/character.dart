import 'package:chronomancer/class.dart';

import 'item.dart';
import 'skill.dart';
import 'util.dart';

class SpentSkill {
  int tree;
  Vector2 pos;
  int rank = 0;
  Skill skill;

  SpentSkill(this.tree, this.pos, this.skill);
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
}
