import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'changelog-dialog',
  styleUrls: ['changelog_dialog.css'],
  templateUrl: 'changelog_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class ChangelogDialogComponent extends ModalComponent {
  static ChangelogDialogComponent INSTANCE;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }
}
