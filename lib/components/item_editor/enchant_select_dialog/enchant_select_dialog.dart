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
  String searchFilter = '';

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  Iterable<Enchant> get enchants => (item == null || !open)
      ? []
      : (item.runeEnchant(slot)
              ? ChronomancerComponent.version.enchants.where((e) =>
                  e.rune != null &&
                  (e.rune.classRequires == null ||
                      e.rune.classRequires ==
                          ChronomancerComponent.character.charClass) &&
                  e.rune.usableOn.contains(item.slot))
              : item
                  .enchantTypesForSlot(slot)
                  .map((e) => ChronomancerComponent.version.enchantPool[
                      ChronomancerComponent.character.charClass][item.slot][e])
                  .flatten)
          .where((e) => !item.enchants
              .where((es) => es != null && item.enchants[slot] != es && es.source != EnchantStackSource.BASE)
              .map((es) => es.enchant)
              .contains(e))
          .where((e) => searchFilter.isEmpty || e.searchText.contains(searchFilter.toLowerCase()));

  void onSelect(Enchant enchant) {
    item.enchants[slot] = EnchantStack(item.sourceOf(slot), enchant,
        enchant.ranges[item.effectiveRarity].maxGreaterAugmented);
    hide();
  }
}
