import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/artifact.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/artifact_dialog/artifact_dialog.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/tooltips/artifact/artifact_tooltip.dart';

@Component(
  selector: 'artifact-slot',
  styleUrls: ['artifact_slot.css'],
  templateUrl: 'artifact_slot.html',
  directives: [],
)
class ArtifactSlotComponent extends CommonComponent {
  @Input()
  int slot;

  Character get character => ChronomancerComponent.character;
  Artifact get artifact => character?.artifacts[slot];

  String get _shape =>
      ARTIFACT_SHAPE_TO_STRING[Artifact.shapeOfSlot(slot)].toLowerCase();
  // the shape icon goes on top of the game's empty slot
  String get background => artifact == null
      ? 'url("assets/images/artifacts/slot_$_shape.png")'
      : 'url("assets/images/artifacts/$_shape.png") center no-repeat, url("assets/images/artifacts/slot_$_shape.png")';

  void onHoverBegin() => ArtifactTooltipComponent.INSTANCE.artifact = artifact;
  void onHoverEnd() => ArtifactTooltipComponent.INSTANCE.artifact = null;

  void onClick() {
    ArtifactDialogComponent.INSTANCE.slot = slot;
    ArtifactDialogComponent.INSTANCE.show();
  }

  void onRightClick(MouseEvent event) {
    event.preventDefault();
    character.artifacts[slot] = null;
    ArtifactTooltipComponent.INSTANCE.artifact = null;
  }
}
