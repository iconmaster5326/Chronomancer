import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/equip_dialog/equip_dialog.dart';
import 'package:chronomancer/components/item_editor/item_editor.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/item.dart';

enum RarityOverlay {
  NONE,
  ORDINARY,
  ENCHANTED,
  RARE,
  UNQIUE,
  LEGENDARY,
  TRUE_LEGENDARY,
  SELECTED,
}
const int RARITY_OVERLAY_SIZE = 24;

enum SlotBack {
  DEFAULT,
  RING,
  FEET,
  BODY,
  AMULET,
  ACCCESSORY,
  WEAPON,
  OFF_HAND,
  HEAD,
}
const int SLOT_BACK_SIZE = 24;

const int ITEM_ICONS_PER_ROW = 32;
const int ITEM_ICON_SIZE = 32;
const int ITEM_ICON_OFFSET = (ITEM_ICON_SIZE - SLOT_BACK_SIZE) ~/ 2;

@Component(
  selector: 'equip-slot',
  styleUrls: ['equip_slot.css'],
  templateUrl: 'equip_slot.html',
  directives: [],
)
class EquipSlotComponent extends SlotComponent {
  Character get character => ChronomancerComponent.character;
  @override
  ItemData get item => character?.equipment[slot];

  void onClick() {
    if (item == null) {
      EquipDialogComponent.INSTANCE.slot = slot;
      EquipDialogComponent.INSTANCE.show();
    } else {
      ItemEditorComponent.editing = character.equipment[slot];
    }
  }

  void onRightClick(MouseEvent event) {
    event.preventDefault();
    EquipDialogComponent.INSTANCE.slot = slot;
    EquipDialogComponent.INSTANCE.show();
  }
}
