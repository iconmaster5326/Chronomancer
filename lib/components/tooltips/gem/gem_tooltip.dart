import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/components/tooltips/item/item_tooltip.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'gem-tooltip',
  styleUrls: ['gem_tooltip.css'],
  templateUrl: 'gem_tooltip.html',
  directives: [coreDirectives, InitDirective, EnchantTextComponent],
)
class GemTooltipComponent extends CommonComponent {
  static GemTooltipComponent INSTANCE;
  ItemData item;
  Gem _gem;
  StreamSubscription<MouseEvent> _conn;
  final TooltipPlacement _placement = TooltipPlacement();

  Gem get gem => _gem;
  set gem(Gem newGem) {
    if (_conn != null) {
      _conn.cancel();
      _conn = null;
    }

    if (newGem != null) {
      _conn = window.onMouseMove.listen(_placement.onMouseMove);
    }

    _gem = newGem;
  }

  void onInit(Element e) {
    _placement.element = e;
    INSTANCE = this;
  }

  String get left => _placement.left;
  String get top => _placement.top;
  EnchantData get enchant => GemSocket(item, null, gem.shape, gem).enchant;
  ItemRarity get _rarity => ItemRarity.values[gem.quality.index];
  String get rarityName => ITEM_RARITY_TO_STRING[_rarity];
  String get shapeName => SHAPE_TO_STRING[gem.shape];
  String get rarityColor => ItemTooltipComponent.RAIRTY_TO_COLOR[_rarity];
}
