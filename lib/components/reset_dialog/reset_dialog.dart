import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/version.dart';

typedef ResetDialogHandler = void Function();

@Component(
  selector: 'reset-dialog',
  styleUrls: ['reset_dialog.css'],
  templateUrl: 'reset_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class ResetDialogComponent extends ModalComponent {
  static ResetDialogComponent INSTANCE;
  ResetDialogHandler confirmHandler;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  void onConfirm() {
    ChronomancerComponent.character = null;
    if (confirmHandler != null) confirmHandler();
    confirmHandler = null;
  }

  void onCancel() {
    confirmHandler = null;
  }
}
