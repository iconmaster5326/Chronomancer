import 'dart:math';

import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
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

  static const Map<int, double> MASTERY_TALLY_MULTIPLIERS_BY_ROW =
      <int, double>{0: 0.3, 1: 0.3, 2: 0.1, 3: 0.1, 4: 0.1, 5: 0.3, 6: 0.3};
  num get masteryTallyPercent =>
      MASTERY_TALLY_MULTIPLIERS_BY_ROW[skill.positions.first.y] * rank;
  num get masteryUnlimitedValue => rank * 10;
  String valueText(String key) {
    if (skill.descVariableValues[key].isEmpty) {
      if (skill.masteryTallySkill) {
        return masteryTallyPercent.toString() + '%';
      } else {
        return masteryUnlimitedValue.toString();
      }
    } else {
      return skill.descVariableValues[key][rank == 0 ? 0 : rank - 1];
    }
  }

  @override
  Iterable<MapEntry<Pattern, ColoredText Function(Match)>> get rules =>
      Skill.DESC_VARIABLES
          .map<MapEntry<Pattern, ColoredText Function(Match)>>((v) => MapEntry(
              RegExp('${v.toUpperCase()}%?'),
              (match) =>
                  ColoredText(SkillTextComponent.COLOR_GREEN, valueText(v))))
          .followedBy([
        MapEntry(
            RegExp(r'_E([^_]*)_([^Â¥]*)Â?¥'),
            (match) => ColoredText(
                EnchantTextComponent.ELEMENT_TO_COLOR[
                    SkillTextComponent.ELEMENT_CODES[match.group(1)]],
                match.group(2))),
        MapEntry(RegExp(r'XDAM\s*'), (match) => ColoredText(null, '')),
        MapEntry(
            RegExp(r'\|([^Â¥]*)Â?¥'),
            (match) => ColoredText(SkillTextComponent.COLOR_GREEN,
                match.group(1).replaceAll('|', ''))),
        MapEntry(
            'REQUIRED',
            (match) => ColoredText(
                SkillTextComponent.COLOR_GREEN,
                ChronomancerComponent.character.modifierOf(skill)?.name ??
                    'The previously selected skill')),
      ]);
}

@Component(
  selector: 'skill-text',
  styleUrls: ['skill_text.css'],
  templateUrl: 'skill_text.html',
  directives: [coreDirectives, InitDirective],
)
class SkillTextComponent extends CommonComponent {
  static const String COLOR_GREEN = '#24c824', COLOR_DARK_RED = '#c80f0f';
  static const ELEMENT_CODES = {
    'ET': SkillElement.ETHEREAL,
    'PH': SkillElement.PHYSICAL,
    'FI': SkillElement.FIRE,
    'LI': SkillElement.LIGHTNING,
    'FR': SkillElement.FROST,
    'PO': SkillElement.POISON,
    'HO': SkillElement.HOLY,
    'SH': SkillElement.SHADOW,
  };

  @Input()
  Skill skill;
  @Input()
  int rank;
  @Input()
  String desc;

  Iterable<ColoredText> get text => SkillTextParser(skill, rank)
      .parse(desc)
      .followedBy(skill.typeName == 'Ultimate Skill'
          ? [
              ColoredText(COLOR_GREEN, ' Ultimate'),
              ColoredText(EnchantTextComponent.COLOR_WHITE, ' skill, '),
              ColoredText(COLOR_DARK_RED, 'can only equip one.'),
            ]
          : []);
  Object trackByEquality(dynamic n, dynamic o) => n == o;
}
