import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/tooltips/item/item_tooltip.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/version.dart';

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
  selector: 'slot',
  styleUrls: ['slot.css'],
  templateUrl: 'slot.html',
  directives: [coreDirectives],
)
class SlotComponent extends CommonComponent {
  @Input()
  ItemType slot;
  @Input()
  ItemData item;
  @Input()
  bool hoverable = true;
  
  bool hovering = false;

  Version get version => ChronomancerComponent.version;

  void onHoverBegin() {
    hovering = true;
    ItemTooltipComponent.INSTANCE.item = item;
  }

  void onHoverEnd() {
    hovering = false;
    ItemTooltipComponent.INSTANCE.item = null;
  }

  RarityOverlay get rarityOverlay {
    if (hoverable && hovering) {
      return RarityOverlay.SELECTED;
    }
    if (item == null) {
      return RarityOverlay.NONE;
    }
    return RarityOverlay.values[item.rarity.index + 1];
  }

  SlotBack get slotBack {
    if (item != null || slot == null) {
      return SlotBack.DEFAULT;
    }
    return SlotBack.values[slot.index + 1];
  }

  String get background {
    // from front to back: rarity overlay, item icon, slot back
    if (item == null) {
      return 'url("assets/images/item_borders.png") -${rarityOverlay.index * RARITY_OVERLAY_SIZE}px 0px, url("assets/images/equipment_slots.png") -${slotBack.index * SLOT_BACK_SIZE}px 0px';
    } else {
      var itemX = item.id % ITEM_ICONS_PER_ROW;
      var itemY = item.id ~/ ITEM_ICONS_PER_ROW;
      return 'url("assets/images/item_borders.png") -${rarityOverlay.index * RARITY_OVERLAY_SIZE}px 0px, url("assets/images/items/${version.name}.png") -${itemX * ITEM_ICON_SIZE + ITEM_ICON_OFFSET}px -${itemY * ITEM_ICON_SIZE + ITEM_ICON_OFFSET}px, url("assets/images/equipment_slots.png") -${slotBack.index * SLOT_BACK_SIZE}px 0px';
    }
  }
}
