import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'item-tooltip',
  styleUrls: ['item_tooltip.css'],
  templateUrl: 'item_tooltip.html',
  directives: [coreDirectives, InitDirective],
)
class ItemTooltipComponent extends CommonComponent {
  static ItemTooltipComponent INSTANCE;
  ItemData _item;
  StreamSubscription<MouseEvent> _conn;
  int _left = 0, _top = 0;

  static const Map<ItemRarity, String> RAIRTY_TO_COLOR = {
    ItemRarity.ORDINARY: '#9132dc',
    ItemRarity.ENCHANTED: '#3c82d2',
    ItemRarity.RARE: '#9132dc',
    ItemRarity.UNIQUE: '#fa14b4',
    ItemRarity.LEGENDARY: '#aa1919',
    ItemRarity.TRUE_LEGENDARY: '#de5021',
  };

  ItemData get item => _item;
  set item(ItemData newItem) {
    if (_conn != null) {
      _conn.cancel();
      _conn = null;
    }

    if (newItem != null) {
      _conn = window.onMouseMove.listen((event) {
        _left = event.page.x;
        _top = event.page.y;
      });
    }

    _item = newItem;
  }

  void onInit() {
    INSTANCE = this;
  }

  String get left => '${_left + 8}px';
  String get top => '${_top + 8}px';
  int get _itemX => item.id % ITEM_ICONS_PER_ROW;
  int get _itemY => item.id ~/ ITEM_ICONS_PER_ROW;
  String get iconBackground =>
      'url("assets/images/items/${ChronomancerComponent.version.name}.png") ${-_itemX * ITEM_ICON_SIZE}px ${-_itemY * ITEM_ICON_SIZE}px';
  String floatingEnchantDesc(List<EnchantType> types) =>
      types.map((t) => ENCHANT_TYPE_TO_STRING[t]).join(' or ');
  String get itemType => []
      .followedBy(item.empowerable && item.empowered ? ['Empowered'] : [])
      .followedBy(item.augmented ? ['Augmented'] : [])
      .followedBy([
        ITEM_RARITY_TO_STRING[item.rarity],
        item.typeName,
      ])
      .followedBy(item.typeName != ITEM_TYPE_TO_STRING[item.type]
          ? ['(${ITEM_TYPE_TO_STRING[item.type]})']
          : [])
      .join(' ');
}
