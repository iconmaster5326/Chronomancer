import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/equip_slot/equip_slot.dart';
import 'package:chronomancer/components/item_editor/enchant_slot/enchant_slot.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'enchant',
  styleUrls: ['enchant.css'],
  templateUrl: 'enchant.html',
  directives: [coreDirectives],
)
class EnchantComponent extends CommonComponent {
  static const int RUNE_ICON_SIZE = 24;

  @Input()
  Enchant enchant;

  int get _runeX =>
      {
        ChronomancerComponent.version.classWithName('Templar'): 1,
        ChronomancerComponent.version.classWithName('Berserker'): 2,
        ChronomancerComponent.version.classWithName('Warden'): 3,
        ChronomancerComponent.version.classWithName('Warlock'): 4,
      }[enchant.rune.classRequires] ??
      0;
  int get _runeY => enchant.rune.greater ? 1 : 0;

  Item get _runeItem => ChronomancerComponent.version.items
      .firstWhere((i) => i.fixedEnchants.contains(enchant), orElse: () => null);
  int get _itemX => _runeItem.id % ITEM_ICONS_PER_ROW;
  int get _itemY => _runeItem.id ~/ ITEM_ICONS_PER_ROW;

  String get iconPackground => (enchant.rune == null || _runeItem == null)
      ? 'url("assets/images/enchants.png") ${-enchant.type.index * EnchantSlotComponent.ENCHANT_ICON_SIZE}px 0px'
      : 'url("assets/images/items/${ChronomancerComponent.version.name}.png") ${-_itemX * ITEM_ICON_SIZE - ITEM_ICON_OFFSET}px ${-_itemY * ITEM_ICON_SIZE - ITEM_ICON_OFFSET}px';
  String get runeVisibility => enchant.rune == null ? 'hidden' : 'visible';
  String get runeBackgroundPos => enchant.rune == null
      ? ''
      : '${-_runeX * RUNE_ICON_SIZE}px ${-_runeY * RUNE_ICON_SIZE}px';
}
