import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'skill-tree',
  styleUrls: ['skill_tree.css'],
  templateUrl: 'skill_tree.html',
  directives: [coreDirectives],
)
class SkillTreeComponent extends CommonComponent {
  static const int ROWS = 7, COLS = 11;

  List<int> get rowIndices => List<int>.generate(ROWS, (i) => i);
  List<int> get colIndices => List<int>.generate(COLS, (i) => i);
}
