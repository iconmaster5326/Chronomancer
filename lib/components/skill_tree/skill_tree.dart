import 'package:angular/angular.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/edge/edge.dart';
import 'package:chronomancer/components/skill_tree/node/node.dart';
import 'package:chronomancer/skill.dart';

@Component(
  selector: 'skill-tree',
  styleUrls: ['skill_tree.css'],
  templateUrl: 'skill_tree.html',
  directives: [coreDirectives, NodeComponent, EdgeComponent],
)
class SkillTreeComponent extends CommonComponent {
  static const int ROWS = 7, COLS = 11;
  static int currentTree = 2;

  CharClass get charClass => ChronomancerComponent.character.charClass;
  List<int> get rowIndices => List<int>.generate(ROWS, (i) => i);
  List<int> get colIndices => List<int>.generate(COLS, (i) => i);
  Iterable<Skill> get skills => ChronomancerComponent.version.skills
      .where((s) => s.charClass == charClass && s.tree == currentTree);
  List<SkillTreeNode> get nodes => skills
      .fold<Map<int, Map<int, SkillTreeNode>>>({}, (map, skill) {
        map
            .putIfAbsent(skill.x, () => {})
            .putIfAbsent(skill.y, () => SkillTreeNode(skill.x, skill.y))
            .skills
            .add(skill);
        return map;
      })
      .values
      .map((m) => m.values)
      .fold<List<SkillTreeNode>>([], (xs, x) => xs..addAll(x))
      .toList();
  List<SkillTreeEdge> get edges => skills
      .map((s1) =>
          s1.requires.map((s2) => SkillTreeEdge(s1.x, s1.y, s2.x, s2.y)))
      .fold<List<SkillTreeEdge>>([], (xs, x) => xs..addAll(x)).toList();

      Object trackByEquality(dynamic n, dynamic o) => n == o;
}
