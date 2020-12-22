import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/item_editor.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/components/tooltips/gem/gem_tooltip.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'gem',
  styleUrls: ['gem.css'],
  templateUrl: 'gem.html',
  directives: [coreDirectives, EnchantTextComponent],
)
class GemComponent extends CommonComponent {
  @Input()
  Gem gem;

  int get _gemX => gem.id % ITEM_ICONS_PER_ROW;
  int get _gemY => gem.id ~/ ITEM_ICONS_PER_ROW;
  String get gemIconBackground =>
      'url("assets/images/items/${gem.version.name}.png") ${-_gemX * ITEM_ICON_SIZE}px ${-_gemY * ITEM_ICON_SIZE}px';
  String get desc => gem.enchants[ItemEditorComponent.editing.type].desc;
  EnchantData get enchant =>
      GemSocket(ItemEditorComponent.editing, null, gem.shape, gem).enchant;

  void onHoverIconBegin() {
    GemTooltipComponent.INSTANCE.item = ItemEditorComponent.editing;
    GemTooltipComponent.INSTANCE.gem = gem;
  }

  void onHoverIconEnd() {
    GemTooltipComponent.INSTANCE.item = null;
    GemTooltipComponent.INSTANCE.gem = null;
  }
}
