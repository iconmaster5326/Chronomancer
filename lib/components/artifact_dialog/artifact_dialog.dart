import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/artifact.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'artifact-dialog',
  styleUrls: ['artifact_dialog.css'],
  templateUrl: 'artifact_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class ArtifactDialogComponent extends ModalComponent {
  static ArtifactDialogComponent INSTANCE;
  int slot;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  Iterable<Artifact> get artifacts => slot == null || !open
      ? <Artifact>[]
      : _character.charClass.version.artifacts
          .where((a) => _character.canHaveArtifact(slot, a));

  Character get _character => ChronomancerComponent.character;

  String icon(Artifact a) =>
      'assets/images/artifacts/${ARTIFACT_SHAPE_TO_STRING[a.shape].toLowerCase()}.png';

  void onArtifactSelected(Artifact artifact) {
    ChronomancerComponent.character.artifacts[slot] = artifact;
    hide();
  }
}
