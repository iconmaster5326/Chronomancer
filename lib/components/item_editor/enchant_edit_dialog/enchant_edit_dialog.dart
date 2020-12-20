import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/enchant_select_dialog/enchant/enchant.dart';
import 'package:chronomancer/components/item_editor/enchant_slot/enchant_slot.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'enchant-edit-dialog',
  styleUrls: ['enchant_edit_dialog.css'],
  templateUrl: 'enchant_edit_dialog.html',
  directives: [coreDirectives, InitDirective, EnchantComponent],
)
class EnchantEditDialogComponent extends ModalComponent {
  static EnchantEditDialogComponent INSTANCE;
  ItemStack item;
  EnchantStack enchant;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  EnchantRange get range => enchant.enchant.ranges[item.rarity];
  String get iconPackgroundPos =>
      '${-enchant.type.index * EnchantSlotComponent.ENCHANT_ICON_SIZE}px 0px';
}
