import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/util.dart';

class SkillTextParser extends Parser<ColoredText> {
  Skill skill;
  int rank;

  SkillTextParser(this.skill, this.rank);

  @override
  ColoredText defaultRule(String s) {
    return ColoredText(EnchantTextComponent.COLOR_WHITE, s);
  }

  @override
  Iterable<MapEntry<Pattern, ColoredText Function(Match)>> get rules => [];
}

@Component(
  selector: 'skill-text',
  styleUrls: ['skill_text.css'],
  templateUrl: 'skill_text.html',
  directives: [coreDirectives, InitDirective],
)
class SkillTextComponent extends CommonComponent {
  @Input()
  Skill skill;
  @Input()
  int rank;
  @Input()
  String desc;

  Iterable<ColoredText> get text => SkillTextParser(skill, rank).parse(desc);
  Object trackByEquality(dynamic n, dynamic o) => n == o;
}
