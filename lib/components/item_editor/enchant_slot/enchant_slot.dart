import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'enchant-slot',
  styleUrls: ['enchant_slot.css'],
  templateUrl: 'enchant_slot.html',
  directives: [coreDirectives],
)
class EnchantSlotComponent extends CommonComponent {
  static const int ENCHANT_ICON_SIZE = 22;

  @Input()
  ItemStack item;
  @Input()
  int slot;
  
  bool hovering = false;

  EnchantStack get enchant => item.enchants[slot];

  String get iconBackground {
    var result = 'url("assets/images/enchants.png") $iconBackgroundPos';
    if (hovering) {
      result = 'url("assets/images/skill_slots.png") -49px -1px, ' + result;
    }
    return result;
  }

  String get iconBackgroundPos =>
      enchant == null ? '' : '${enchant.type.index * -ENCHANT_ICON_SIZE}px 0px';

  String get _choiceString => item
      .enchantTypesForSlot(slot)
      .map((type) => ENCHANT_TYPE_TO_STRING[type])
      .join(' or ');
  String get name =>
      enchant == null ? '(random ${_choiceString} enchantment)' : enchant.name;
}
