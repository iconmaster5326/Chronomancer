import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'enchant-text',
  styleUrls: ['enchant_text.css'],
  templateUrl: 'enchant_text.html',
  directives: [coreDirectives, InitDirective],
)
class EnchantTextComponent extends CommonComponent {
  static const COLOR_WHITE = 'white',
      COLOR_ORANGE = '#d2823c',
      COLOR_RED = '#de5021',
      COLOR_BLUE = '#00beff';
  static const SOURCE_TO_COLOR = {
    EnchantStackSource.BASE: COLOR_ORANGE,
    EnchantStackSource.FIXED: COLOR_ORANGE,
    EnchantStackSource.RUNE: COLOR_RED,
    EnchantStackSource.FLOATING: COLOR_WHITE,
  };

  @Input()
  EnchantData enchant;
  @Input()
  ItemData item;
  @Input()
  bool bulleted = true;

  EnchantRange get range => enchant.ranges[item?.rarity];
  String get _defaultColor => enchant.type == EnchantType.LEGENDARY
      ? COLOR_RED
      : SOURCE_TO_COLOR[enchant.source];
  Iterable<ColoredText> get text => enchant.desc
      .split('AMOUNT')
      .map((t) => ColoredText(_defaultColor, t))
      .intersperse(ColoredText(
          COLOR_BLUE,
          enchant.value == null && range != null
              ? '(${range.min},${range.max}) [${range.maxAugmented}] [[${range.maxGreaterAugmented}]]'
              : enchant.value.toString()));
  bool get showBullet => bulleted && enchant.source != EnchantStackSource.BASE;
}
