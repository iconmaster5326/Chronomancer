import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/enchant_select_dialog/enchant/enchant.dart';
import 'package:chronomancer/enchant.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'enchant-select-dialog',
  styleUrls: ['enchant_select_dialog.css'],
  templateUrl: 'enchant_select_dialog.html',
  directives: [coreDirectives, InitDirective, EnchantComponent],
)
class EnchantSelectDialogComponent extends ModalComponent {
  static EnchantSelectDialogComponent INSTANCE;
  ItemStack item;
  int slot;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  Iterable<Enchant> get enchants => item == null
      ? []
      : item
          .enchantTypesForSlot(slot)
          .map((e) => ChronomancerComponent.version
                  .enchantPool[ChronomancerComponent.character.charClass]
              [item.slot][e])
          .flatten;

  void onSelect(Enchant enchant) {
    item.enchants[slot] =
        EnchantStack(enchant, enchant.ranges[item.rarity].maxGreaterAugmented);
    hide();
  }
}
