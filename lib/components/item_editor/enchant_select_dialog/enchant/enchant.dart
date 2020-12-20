import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
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
  static const int RUNE_ICON_SIZE = 24;

  @Input()
  Enchant enchant;

  int get _runeX =>
      {
        ChronomancerComponent.version.classWithName('Templar'): 1,
        ChronomancerComponent.version.classWithName('Berserker'): 2,
        ChronomancerComponent.version.classWithName('Warden'): 3,
        ChronomancerComponent.version.classWithName('Warlock'): 4,
      }[enchant.rune.classRequires] ??
      0;
  int get _runeY => enchant.rune.greater ? 1 : 0;

  String get iconPackgroundPos =>
      '${-enchant.type.index * EnchantSlotComponent.ENCHANT_ICON_SIZE}px 0px';
  String get runeVisibility => enchant.rune == null ? 'hidden' : 'visible';
  String get runeBackgroundPos => enchant.rune == null
      ? ''
      : '${-_runeX * RUNE_ICON_SIZE}px ${-_runeY * RUNE_ICON_SIZE}px';
}
