import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/enchant_slot/enchant_slot.dart';
import 'package:chronomancer/enchant.dart';

@Component(
  selector: 'enchant',
  styleUrls: ['enchant.css'],
  templateUrl: 'enchant.html',
  directives: [coreDirectives],
)
class EnchantComponent extends CommonComponent {
  @Input()
  Enchant enchant;

  String get iconPackgroundPos =>
      '${-enchant.type.index * EnchantSlotComponent.ENCHANT_ICON_SIZE}px 0px';
}
