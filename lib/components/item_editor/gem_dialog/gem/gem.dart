import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/gem.dart';

@Component(
  selector: 'gem',
  styleUrls: ['gem.css'],
  templateUrl: 'gem.html',
  directives: [coreDirectives],
)
class GemComponent extends CommonComponent {
  @Input()
  Gem gem;

  int get _gemX => gem.id % ITEM_ICONS_PER_ROW;
  int get _gemY => gem.id ~/ ITEM_ICONS_PER_ROW;
  String get gemIconBackground =>
      'url("assets/images/items/${gem.version.name}.png") ${-_gemX * ITEM_ICON_SIZE}px ${-_gemY * ITEM_ICON_SIZE}px';
}
