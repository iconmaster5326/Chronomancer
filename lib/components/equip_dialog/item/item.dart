import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'item',
  styleUrls: ['item.css'],
  templateUrl: 'item.html',
  directives: [coreDirectives, InitDirective, SlotComponent],
)
class ItemComponent extends CommonComponent {
  @Input()
  Item item;
}
