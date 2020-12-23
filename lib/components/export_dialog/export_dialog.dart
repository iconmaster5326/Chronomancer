import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'export-dialog',
  styleUrls: ['export_dialog.css'],
  templateUrl: 'export_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class ExportDialogComponent extends ModalComponent {
  static ExportDialogComponent INSTANCE;
  String title, desc, exportedText;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }
}
