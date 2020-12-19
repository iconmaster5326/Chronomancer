import 'dart:math';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/skill_tree/node/node.dart';

class SkillTreeEdge {
  int x1, y1, x2, y2;

  SkillTreeEdge(this.x1, this.y1, this.x2, this.y2);

  @override
  bool operator ==(dynamic other) {
    if (other is! SkillTreeEdge) {
      return false;
    }

    if (!(x1 == other.x1 &&
        y1 == other.y1 &&
        x2 == other.x2 &&
        y2 == other.y2)) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => x1 + y1 + x2 + y2;
}

@Component(
  selector: 'skill-tree-edge',
  styleUrls: ['edge.css'],
  templateUrl: 'edge.html',
  directives: [coreDirectives],
)
class EdgeComponent extends CommonComponent {
  @Input()
  SkillTreeEdge edge;

  int treeToPixelCoord(int pos) {
    return pos *
            (NodeComponent.SKILL_ICON_SIZE + NodeComponent.SKILL_ICON_PADDING) +
        NodeComponent.SKILL_ICON_SIZE ~/ 2;
  }

  double get distance =>
      sqrt(pow(treeToPixelCoord(edge.x2) - treeToPixelCoord(edge.x1), 2) +
          pow(treeToPixelCoord(edge.y2) - treeToPixelCoord(edge.y1), 2));
  double get angle => atan2(edge.y2 - edge.y1, edge.x2 - edge.x1);

  String get posLeft => '${treeToPixelCoord(edge.x1)}px';
  String get posTop => '${treeToPixelCoord(edge.y1)}px';
  String get width => '${distance.toInt()}px';
  String get transform => 'rotate(${angle}rad)';
}
