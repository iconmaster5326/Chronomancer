import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/skill_dialog/skill/skill.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'skill-dialog',
  styleUrls: ['skill_dialog.css'],
  templateUrl: 'skill_dialog.html',
  directives: [coreDirectives, InitDirective, SkillComponent],
)
class SkillDialogComponent extends ModalComponent {
  static SkillDialogComponent INSTANCE;
  int rank;
  Vector2 pos;
  List<Skill> skills;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  void onSkillSelected(Skill skill) {
    var spentSkill = SpentSkill(ChronomancerComponent.character,
        SkillTreeComponent.currentTree, pos, skill);
    spentSkill.rank = rank;
    ChronomancerComponent.character.skills[SkillTreeComponent.currentTree]
        [pos] = spentSkill;
    hide();
  }
}
