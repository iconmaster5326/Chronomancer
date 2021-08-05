import 'package:angular/angular.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/edge/edge.dart';
import 'package:chronomancer/components/skill_tree/node/node.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'skill-tree',
  styleUrls: ['skill_tree.css'],
  templateUrl: 'skill_tree.html',
  directives: [coreDirectives, NodeComponent, EdgeComponent],
)
class SkillTreeComponent extends CommonComponent {
  static const int ROWS = 7, COLS = 11;
  static int currentTree = 2;

  static String skillTypeToClipPath(SkillType type) {
    switch (type) {
      case SkillType.PASSIVE:
        return 'circle(45%)';
      case SkillType.PERK:
        return 'polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%)';
      case SkillType.AURA:
        return 'polygon(75% 0%, 100% 25%, 100% 75%, 75% 100%, 25% 100%, 0% 75%, 0% 25%, 25% 0%)';
      default:
        return '';
    }
  }

  CharClass get charClass => ChronomancerComponent.character.charClass;
  List<int> get rowIndices => List<int>.generate(ROWS, (i) => i);
  List<int> get colIndices => List<int>.generate(COLS, (i) => i);
  Iterable<Skill> get skills =>
      ChronomancerComponent.version.skills.where((s) =>
          s.charClass == charClass &&
          s.tree == currentTree &&
          s.positions.every((p) => p.x >= 0 && p.y >= 0));

  List<SkillTreeNode> get nodes => skills
      .fold<Map<int, Map<int, SkillTreeNode>>>({}, (map, skill) {
        for (var pos in skill.positions) {
          map
              .putIfAbsent(pos.x, () => {})
              .putIfAbsent(pos.y, () => SkillTreeNode(pos.x, pos.y))
              .skills
              .add(skill);
        }
        return map;
      })
      .values
      .map((m) => m.values)
      .flatten;

  List<SkillTreeEdge> get _masteryEdges => List<List<SkillTreeEdge>>.generate(
      COLS - 3,
      (x) => List<SkillTreeEdge>.generate(
          ROWS,
          (y) => SkillTreeEdge(
              x + 2,
              y,
              x + 3,
              (x == 7 && y == 2)
                  ? y + 1
                  : (x == 7 && y == 4)
                      ? y - 1
                      : y))).flatten;
  List<SkillTreeEdge> get _nonMasteryEdges => skills
      .map((s1) => s1.positions.map((pos1) => s1.requires.map((s2) => s2
          .positions
          .map((pos2) => SkillTreeEdge(pos1.x, pos1.y, pos2.x, pos2.y)))))
      .flatten
      .flatten
      .flatten;
  List<SkillTreeEdge> get edges =>
      currentTree == Skill.TREE_MASTERY ? _masteryEdges : _nonMasteryEdges;

  Object trackByEquality(dynamic n, dynamic o) => n == o;

  // String get backgroundSize =>
  //     '${(1 - ChronomancerComponent.character.pointsSpentIn(currentTree) / ChronomancerComponent.character.charClass.maxPointsInTree(currentTree)) * 100}%';
  String get backgroundSize => '0';
}
