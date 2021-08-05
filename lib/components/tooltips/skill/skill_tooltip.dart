import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/node/node.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/components/tooltips/skill/text/skill_text.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'skill-tooltip',
  styleUrls: ['skill_tooltip.css'],
  templateUrl: 'skill_tooltip.html',
  directives: [
    coreDirectives,
    InitDirective,
    EnchantTextComponent,
    SkillTextComponent
  ],
)
class SkillTooltipComponent extends CommonComponent {
  static SkillTooltipComponent INSTANCE;
  int rankOverride;
  Skill _skill;
  StreamSubscription<MouseEvent> _conn;
  int _left = 0, _top = 0;

  Skill get skill => _skill;
  set skill(Skill newSkill) {
    if (_conn != null) {
      _conn.cancel();
      _conn = null;
    }

    if (newSkill != null) {
      _conn = window.onMouseMove.listen((event) {
        _left = event.page.x;
        _top = event.page.y;
      });
    }

    _skill = newSkill;
  }

  void onInit() {
    INSTANCE = this;
  }

  SpentSkill get spentSkill =>
      ChronomancerComponent.character.findSpentSkill(skill);
  String get left => '${_left + 8}px';
  String get top => '${_top + 8}px';
  bool get showNextRank =>
      !skill.tallySkill &&
      skill.rankUpDesc != null &&
      skill.maxRank != null &&
      skill.maxRank != 1 &&
      rank != skill.maxRank;
  bool get nextOrMax =>
      (skill.maxRank == null || (spentSkill != null && rank != 0));
  String get nextRankHeader => nextOrMax ? 'At Next Rank:' : 'At Max Rank:';
  bool get unlockable => ChronomancerComponent.character.skillUnlocked(skill);
  String get color => EnchantTextComponent.ELEMENT_TO_COLOR[skill.element];
  int get rank {
    if (rankOverride != null) {
      return rankOverride;
    } else if (skill.masteryTallySkill) {
      return ChronomancerComponent.character
          .pointsSpentInRow(skill.tree, skill.positions.first.y);
    } else if (skill.tallySkill) {
      return ChronomancerComponent.character.pointsSpentIn(skill.tree);
    } else {
      return spentSkill?.rank ?? 0;
    }
  }

  String get family => skill.family == null ? '' : ', ${skill.family}';
  int get level => ChronomancerComponent.character.level;

  // begin copy-pasted from node.dart TODO: do not copy paste
  String get iconClipPath => SkillTreeComponent.skillTypeToClipPath(skill.type);
  String get iconBackground {
    var skillBorder = [NodeMode.FILLED]
        .map((mode) =>
            'url("assets/images/skill_slots.png") ${-(mode.index * NodeComponent.SKILL_BORDER_SIZE)}px ${-(skill.type.index * NodeComponent.SKILL_BORDER_SIZE)}px')
        .join(', ');

    if (!ChronomancerComponent.character.skillUnlocked(skill)) {
      skillBorder += ', linear-gradient(rgba(0,0,0,0.5),rgba(0,0,0,0.5))';
    }

    var id = NodeComponent.effectiveID(skill);
    var skillX = id % NodeComponent.SKILL_ICONS_PER_ROW;
    var skillY = id ~/ NodeComponent.SKILL_ICONS_PER_ROW;
    return skillBorder +
        ', url("assets/images/skills/${ChronomancerComponent.version.name}.png") ${-skillX * NodeComponent.SKILL_ICON_SIZE + 1}px ${-skillY * NodeComponent.SKILL_ICON_SIZE + 1}px';
  }
  //end copy-pasted from node
}
