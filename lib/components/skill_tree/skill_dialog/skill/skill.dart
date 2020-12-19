import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/node/node.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/skill.dart';

@Component(
  selector: 'skill',
  styleUrls: ['skill.css'],
  templateUrl: 'skill.html',
  directives: [coreDirectives, InitDirective, SlotComponent],
)
class SkillComponent extends CommonComponent {
  @Input()
  Skill skill;

  int get iconX => skill.id % NodeComponent.SKILL_ICONS_PER_ROW;
  int get iconY => skill.id ~/ NodeComponent.SKILL_ICONS_PER_ROW;
  String get iconBackground =>
      'url("assets/images/skill_slots.png") -24px ${-NodeComponent.SKILL_BORDER_SIZE * skill.type.index}px, url("assets/images/skills/${skill.version.name}.png") ${-iconX * NodeComponent.SKILL_ICON_SIZE + 1}px ${-iconY * NodeComponent.SKILL_ICON_SIZE}px';
  String get iconClipPath => SkillTreeComponent.skillTypeToClipPath(skill.type);
}
