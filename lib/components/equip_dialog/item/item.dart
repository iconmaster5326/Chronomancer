import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'item',
  styleUrls: ['item.css'],
  templateUrl: 'item.html',
  directives: [
    coreDirectives,
    InitDirective,
    SlotComponent,
    EnchantTextComponent,
  ],
)
class ItemComponent extends CommonComponent {
  @Input()
  Item item;

  String floatingEnchantDesc(List<EnchantType> types) =>
      types.map((t) => ENCHANT_TYPE_TO_STRING[t]).join(' or ');
}
