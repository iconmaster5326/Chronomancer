import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
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
}
