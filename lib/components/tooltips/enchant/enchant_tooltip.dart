import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/tooltips/enchant/text/enchant_text.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'enchant-tooltip',
  styleUrls: ['enchant_tooltip.css'],
  templateUrl: 'enchant_tooltip.html',
  directives: [coreDirectives, InitDirective, EnchantTextComponent],
)
class EnchantTooltipComponent extends CommonComponent {
  static EnchantTooltipComponent INSTANCE;
  ItemData item;
  EnchantData _enchant;
  StreamSubscription<MouseEvent> _conn;
  final TooltipPlacement _placement = TooltipPlacement();

  EnchantData get enchant => _enchant;
  set enchant(EnchantData newEnchant) {
    if (_conn != null) {
      _conn.cancel();
      _conn = null;
    }

    if (newEnchant != null) {
      _conn = window.onMouseMove.listen(_placement.onMouseMove);
    }

    _enchant = newEnchant;
  }

  void onInit(Element e) {
    _placement.element = e;
    INSTANCE = this;
  }

  String get left => _placement.left;
  String get top => _placement.top;
  EnchantRange get range => enchant.ranges[item.rarity];
}
