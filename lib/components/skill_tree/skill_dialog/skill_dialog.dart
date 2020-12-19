import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/skill_dialog/skill/skill.dart';
import 'package:chronomancer/skill.dart';

@Component(
  selector: 'skill-dialog',
  styleUrls: ['skill_dialog.css'],
  templateUrl: 'skill_dialog.html',
  directives: [coreDirectives, InitDirective, SkillComponent],
)
class SkillDialogComponent extends ModalComponent {
  static SkillDialogComponent INSTANCE;
  List<Skill> skills;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  void onSkillSelected(Skill skill) {}
}
