import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/enchant_slot/enchant_slot.dart';
import 'package:chronomancer/components/item_editor/gem_socket/gem_socket.dart';
import 'package:chronomancer/components/item_editor/socket_config_dialog/socket_config_dialog.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'item-editor',
  styleUrls: ['item_editor.css'],
  templateUrl: 'item_editor.html',
  directives: [coreDirectives, SlotComponent, EnchantSlotComponent, GemSocketComponent],
)
class ItemEditorComponent extends CommonComponent {
  static ItemStack editing;

  void onRerollGems() {
    SocketConfigDialogComponent.INSTANCE.item = editing;
    SocketConfigDialogComponent.INSTANCE.show();
  }

  String rarityName(ItemRarity rarity) => ITEM_RARITY_TO_STRING[rarity];

  void setRarity(ItemRarity rarity) {
    editing.rarity = rarity;
    editing.regenerateMutableEnchants();
  }

  void toggleEmpowered() {
    editing.empowered = !editing.empowered;
    editing.clampEnchantValues();
  }
}
