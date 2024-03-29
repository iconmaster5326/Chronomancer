import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/skill_dialog/skill_dialog.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/components/tooltips/skill/skill_tooltip.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/util.dart';

class SkillTreeNode {
  int x, y;
  List<Skill> skills = [];

  SkillTreeNode(this.x, this.y);

  @override
  bool operator ==(dynamic other) {
    if (other is! SkillTreeNode) {
      return false;
    }

    if (!(x == other.x &&
        y == other.y &&
        skills.length == other.skills.length)) {
      return false;
    }

    for (var i = 0; i < skills.length; i++) {
      if (skills[i] != other.skills[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => skills.fold(x + y, (sum, skill) => sum + skill.hashCode);
}

enum NodeMode {
  EMPTY,
  FILLED,
  SELECTED,
}

@Component(
  selector: 'skill-tree-node',
  styleUrls: ['node.css'],
  templateUrl: 'node.html',
  directives: [coreDirectives],
)
class NodeComponent extends CommonComponent {
  static const int SKILL_BORDER_SIZE = 24,
      SKILL_ICON_SIZE = 22,
      SKILL_ICONS_PER_ROW = 32,
      SKILL_ICON_PADDING = 8,
      MASTERY_ID_OFFSET = 100000;

  static int effectiveID(Skill skill) => skill.id < MASTERY_ID_OFFSET
      ? skill.id
      : skill.id -
          MASTERY_ID_OFFSET +
          skill.version.skills
              .where((s) => s.tree != Skill.TREE_MASTERY)
              .map((s) => s.id)
              .max +
          1;

  @Input()
  SkillTreeNode node;

  bool hovering = false;

  void onHoverBegin() {
    hovering = true;
    SkillTooltipComponent.INSTANCE.skill = (node.skills.length == 1
        ? node.skills.first
        : ChronomancerComponent
            .character
            .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)]
            ?.skill);
  }

  void onHoverEnd() {
    hovering = false;
    SkillTooltipComponent.INSTANCE.skill = null;
  }

  Skill get filledWith => node.skills.length == 1
      ? node.skills.first
      : ChronomancerComponent
          .character
          .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)]
          ?.skill;
  Iterable<NodeMode> get modes {
    var filledMode = filledWith == null ? NodeMode.EMPTY : NodeMode.FILLED;
    if (hovering) {
      return [NodeMode.SELECTED, filledMode];
    } else {
      return [filledMode];
    }
  }

  int get rank {
    var r = 0;
    if (node.skills.first.masteryTallySkill) {
      r = ChronomancerComponent.character
          .pointsSpentInRow(SkillTreeComponent.currentTree, node.y);
    } else if (node.skills.first.tallySkill) {
      r = ChronomancerComponent.character
          .pointsSpentIn(SkillTreeComponent.currentTree);
    } else {
      r = ChronomancerComponent
          .character
          .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)]
          ?.rank;
    }
    return r == 0 ? null : r;
  }

  SkillType get type => node.skills.first.type;
  CharClass get charClass => ChronomancerComponent.character.charClass;

  String get clipPath {
    if (node.skills.isEmpty || filledWith == null) {
      return '';
    }

    return SkillTreeComponent.skillTypeToClipPath(type);
  }

  String get background {
    var skillBorder = modes
        .map((mode) =>
            'url("assets/images/skill_slots.png") ${-(mode.index * SKILL_BORDER_SIZE)}px ${-(type.index * SKILL_BORDER_SIZE)}px')
        .join(', ');

    var skill = filledWith;
    if (skill == null) {
      return skillBorder;
    }

    if (!ChronomancerComponent.character.skillUnlocked(skill)) {
      skillBorder += ', linear-gradient(rgba(0,0,0,0.5),rgba(0,0,0,0.5))';
    }

    var id = effectiveID(skill);
    var skillX = id % SKILL_ICONS_PER_ROW;
    var skillY = id ~/ SKILL_ICONS_PER_ROW;
    return skillBorder +
        ', url("assets/images/skills/${ChronomancerComponent.version.name}.png") ${-skillX * SKILL_ICON_SIZE + 1}px ${-skillY * SKILL_ICON_SIZE + 1}px';
  }

  String get levelBoxBackground => node.skills.first.tallySkill
      ? ''
      : 'url("assets/images/skill_level_box.png")';

  String get posLeft => '${node.x * (SKILL_ICON_SIZE + SKILL_ICON_PADDING)}px';
  String get posTop => '${node.y * (SKILL_ICON_SIZE + SKILL_ICON_PADDING)}px';

  List<Skill> get validSkills {
    var thisSpentSkill = ChronomancerComponent.character
        .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)];
    return SkillTreeComponent.currentTree == Skill.TREE_MASTERY
        ? node.skills.where((skill) {
            var spentSkill =
                ChronomancerComponent.character.findSpentSkill(skill);
            return spentSkill == null || spentSkill == thisSpentSkill;
          }).toList()
        : node.skills;
  }

  void onClick(MouseEvent event) {
    event.preventDefault();

    if (node.skills.first.tallySkill) {
      return;
    }

    if (filledWith == null) {
      SkillDialogComponent.INSTANCE.rank = 0;
      SkillDialogComponent.INSTANCE.skills = validSkills;
      SkillDialogComponent.INSTANCE.pos = Vector2(node.x, node.y);
      SkillDialogComponent.INSTANCE.show();
    } else {
      var pos = Vector2(node.x, node.y);
      var spentSkill = ChronomancerComponent
          .character.skills[SkillTreeComponent.currentTree]
          .putIfAbsent(
              pos,
              () => SpentSkill(ChronomancerComponent.character,
                  SkillTreeComponent.currentTree, pos, node.skills.first));

      if (event.shiftKey || event.ctrlKey) {
        if (ChronomancerComponent.respeccing) {
          while (spentSkill.canRankDown) {
            spentSkill.rank--;
          }
        } else {
          if (spentSkill.skill.maxRank == null) return;

          while (spentSkill.canRankUp) {
            spentSkill.rank++;
          }
        }
      } else {
        if (ChronomancerComponent.respeccing) {
          if (spentSkill.canRankDown) {
            spentSkill.rank--;
          }
        } else {
          if (spentSkill.canRankUp) {
            spentSkill.rank++;
          }
        }
      }
    }
  }

  void onRightClick(MouseEvent event) {
    event.preventDefault();

    if (event.shiftKey || event.ctrlKey) {
      if (node.skills.length > 1 &&
          ChronomancerComponent
                  .character
                  .skills[SkillTreeComponent.currentTree]
                      [Vector2(node.x, node.y)]
                  ?.rank ==
              0) {
        ChronomancerComponent.character.skills[SkillTreeComponent.currentTree]
            .remove(Vector2(node.x, node.y));
      }
      return;
    }

    if (node.skills.length > 1) {
      SkillDialogComponent.INSTANCE.rank = ChronomancerComponent
              .character
              .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)]
              ?.rank ??
          0;
      SkillDialogComponent.INSTANCE.skills = validSkills;
      SkillDialogComponent.INSTANCE.pos = Vector2(node.x, node.y);
      SkillDialogComponent.INSTANCE.show();
    }
  }

  String get rankColor {
    if (node.skills.first.masteryTallySkill) {
      return EnchantTextComponent.COLOR_WHITE;
    } else if (ChronomancerComponent
            .character
            .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)]
            ?.rank ==
        filledWith?.maxRank) {
      return EnchantTextComponent.COLOR_ORANGE;
    } else {
      return EnchantTextComponent.COLOR_WHITE;
    }
  }
}
