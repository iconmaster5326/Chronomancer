import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'about-dialog',
  styleUrls: ['about_dialog.css'],
  templateUrl: 'about_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class AboutDialogComponent extends ModalComponent {
  static AboutDialogComponent INSTANCE;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }
}
