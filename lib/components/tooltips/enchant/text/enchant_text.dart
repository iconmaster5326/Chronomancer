import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';

class EnchantTextParser extends Parser<ColoredText> {
  EnchantData enchant;
  ItemData item;

  EnchantTextParser(this.enchant, this.item);

  EnchantRange get _range => enchant.ranges[item?.rarity];

  @override
  ColoredText defaultRule(String s) {
    return ColoredText(
        enchant.type == EnchantType.LEGENDARY
            ? EnchantTextComponent.COLOR_RED
            : EnchantTextComponent.SOURCE_TO_COLOR[enchant.source],
        s);
  }

  @override
  Iterable<MapEntry<Pattern, ColoredText Function(Match)>> get rules => [
        MapEntry(
            'AMOUNT%',
            (match) => ColoredText(
                EnchantTextComponent.COLOR_BLUE,
                enchant.value == null && _range != null
                    ? '(${_range.min},${_range.max}) [${_range.maxAugmented}] [[${_range.maxGreaterAugmented}]]%'
                    : enchant.value.toString())),
        MapEntry(
            'AMOUNT',
            (match) => ColoredText(
                EnchantTextComponent.COLOR_BLUE,
                enchant.value == null && _range != null
                    ? '(${_range.min},${_range.max}) [${_range.maxAugmented}] [[${_range.maxGreaterAugmented}]]'
                    : enchant.value.toString())),
        MapEntry(
            RegExp(r'<SKILL_(\d+)>'),
            (match) => ColoredText(
                EnchantTextComponent.COLOR_WHITE,
                ChronomancerComponent.version.skills
                    .firstWhere((s) => s.id == int.parse(match.group(1)))
                    .name)),
      ];
}

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

  Iterable<ColoredText> get text =>
      EnchantTextParser(enchant, item).parse(enchant.desc);
  bool get showBullet => bulleted && enchant.source != EnchantStackSource.BASE;

  Object trackByEquality(dynamic n, dynamic o) => n == o;
}
