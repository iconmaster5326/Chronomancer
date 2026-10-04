import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/artifact.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'artifact-tooltip',
  styleUrls: ['artifact_tooltip.css'],
  templateUrl: 'artifact_tooltip.html',
  directives: [coreDirectives, InitDirective],
)
class ArtifactTooltipComponent extends CommonComponent {
  static ArtifactTooltipComponent INSTANCE;
  Artifact _artifact;
  StreamSubscription<MouseEvent> _conn;
  final TooltipPlacement _placement = TooltipPlacement();

  Artifact get artifact => _artifact;
  set artifact(Artifact newArtifact) {
    if (_conn != null) {
      _conn.cancel();
      _conn = null;
    }

    if (newArtifact != null) {
      _conn = window.onMouseMove.listen(_placement.onMouseMove);
    }

    _artifact = newArtifact;
  }

  void onInit(Element e) {
    _placement.element = e;
    INSTANCE = this;
  }

  String get left => _placement.left;
  String get top => _placement.top;
  String get shapeName => ARTIFACT_SHAPE_TO_STRING[artifact.shape];
  String get icon => 'assets/images/artifacts/${shapeName.toLowerCase()}.png';
}
