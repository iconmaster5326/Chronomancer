import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/equip_dialog/item/item.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'equip-dialog',
  styleUrls: ['equip_dialog.css'],
  templateUrl: 'equip_dialog.html',
  directives: [coreDirectives, InitDirective, ItemComponent],
)
class EquipDialogComponent extends ModalComponent {
  static EquipDialogComponent INSTANCE;
  ItemType slot;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  Iterable<Item> get items {
    if (slot == null) {
      return <Item>[];
    } else {
      return ChronomancerComponent.version.items.where((item) =>
          item.type == slot &&
          (item.requiresClass == null ||
              item.requiresClass == ChronomancerComponent.character.charClass));
    }
  }

  void onItemSelected(Item item) {
    ChronomancerComponent.character.equipment[slot] = ItemStack(item);
    hide();
  }
}
