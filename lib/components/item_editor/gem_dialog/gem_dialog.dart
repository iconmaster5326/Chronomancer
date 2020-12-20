import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/gem_dialog/gem/gem.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'gem-dialog',
  styleUrls: ['gem_dialog.css'],
  templateUrl: 'gem_dialog.html',
  directives: [coreDirectives, InitDirective, GemComponent],
)
class GemDialogComponent extends ModalComponent {
  static const GemQuality QUALITY_ROUGH = GemQuality.ROUGH;
  static const GemQuality QUALITY_CUT = GemQuality.CUT;
  static const GemQuality QUALITY_POLISHED = GemQuality.POLISHED;

  static GemDialogComponent INSTANCE;
  GemSocket socket;
  GemQuality quality = GemQuality.POLISHED;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  String get qualityName {
    switch (quality) {
      case GemQuality.ROUGH:
        return 'Rough';
      case GemQuality.CUT:
        return 'Cut';
      case GemQuality.POLISHED:
        return 'Polished';
      default:
        return null;
    }
  }

  Iterable<Gem> get gems => socket == null
      ? []
      : ChronomancerComponent.version.gems
          .where((gem) => gem.quality == quality && gem.shape == socket.shape);

  void onGemSelected(Gem gem) {
    socket.gem = gem;
    hide();
  }
}
