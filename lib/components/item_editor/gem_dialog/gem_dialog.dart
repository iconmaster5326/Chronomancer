import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'gem-dialog',
  styleUrls: ['gem_dialog.css'],
  templateUrl: 'gem_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class GemDialogComponent extends ModalComponent {
  static GemDialogComponent INSTANCE;
  GemSocket socket;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  void onGemSelected(Gem gem) {
    
  }
}
