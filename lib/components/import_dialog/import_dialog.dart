import 'dart:convert';
import 'dart:html' as html;

import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'import-dialog',
  styleUrls: ['import_dialog.css'],
  templateUrl: 'import_dialog.html',
  directives: [coreDirectives, InitDirective],
)
class ImportDialogComponent extends ModalComponent {
  static ImportDialogComponent INSTANCE;

  @override
  void init(html.Element e) {
    super.init(e);
    INSTANCE = this;
  }

  void onKeyPress(html.TextAreaElement textarea, html.KeyboardEvent event) {
    if (event.keyCode == 13) {
      event.preventDefault();
      onImport(textarea.value);
    }
  }

  void onImport(String s) {
    try {
      ChronomancerComponent.character = Character.fromJSON(
          ChronomancerComponent.versions,
          json.decode(utf8.decode(base64.decode(s))));
      hide();
    } on FormatException {
      html.window.alert(
          'Could not read build! Ensure you pasted the correct text into the box.');
    }
  }
}
