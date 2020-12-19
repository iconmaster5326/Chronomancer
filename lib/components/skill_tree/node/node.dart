import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/skill_dialog/skill_dialog.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
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
      SKILL_ICON_PADDING = 8;

  @Input()
  SkillTreeNode node;

  bool hovering = false;

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
    var r = node.skills.first.tallySkill
        ? ChronomancerComponent.character
            .pointsSpentIn(SkillTreeComponent.currentTree)
        : ChronomancerComponent
            .character
            .skills[SkillTreeComponent.currentTree][Vector2(node.x, node.y)]
            ?.rank;
    return r == 0 ? null : r;
  }

  SkillType get type => node.skills.first.type;
  CharClass get charClass => ChronomancerComponent.character.charClass;

  String get clipPath {
    if (node.skills.isEmpty || filledWith == null) {
      return '';
    }

    switch (type) {
      case SkillType.PASSIVE:
        return 'circle(45%)';
      case SkillType.PERK:
        return 'polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%)';
      default:
        return '';
    }
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

    var skillX = skill.id % SKILL_ICONS_PER_ROW;
    var skillY = skill.id ~/ SKILL_ICONS_PER_ROW;
    return skillBorder +
        ', url("assets/images/skills/${ChronomancerComponent.version.name}.png") ${-skillX * SKILL_ICON_SIZE + 1}px ${-skillY * SKILL_ICON_SIZE}px';
  }

  String get levelBoxBackground => node.skills.first.tallySkill
      ? ''
      : 'url("assets/images/skill_level_box.png")';

  String get posLeft => '${node.x * (SKILL_ICON_SIZE + SKILL_ICON_PADDING)}px';
  String get posTop => '${node.y * (SKILL_ICON_SIZE + SKILL_ICON_PADDING)}px';

  void onClick() {
    if (node.skills.first.tallySkill) {
      return;
    }

    if (filledWith == null) {
      SkillDialogComponent.INSTANCE.skills = node.skills;
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

      if (spentSkill.canRankUp) {
        spentSkill.rank++;
      }
    }
  }
}
