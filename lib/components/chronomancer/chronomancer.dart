import 'package:angular/angular.dart';
import 'package:chronomancer/components/char_sel/char_sel.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/equip_dialog/equip_dialog.dart';
import 'package:chronomancer/components/equip_slot/equip_slot.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/components/skill_tree_tab/skill_tree_tab.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/version.dart';
import 'package:http/http.dart';

@Component(
  selector: 'chronomancer',
  styleUrls: ['chronomancer.css'],
  templateUrl: 'chronomancer.html',
  directives: [
    coreDirectives,
    CharSelCompoment,
    EquipSlotComponent,
    EquipDialogComponent,
    SkillTreeComponent,
    SkillTreeTabComponent,
  ],
)
class ChronomancerComponent {
  static const ItemType ITEM_TYPE_HEAD = ItemType.HEAD;
  static const ItemType ITEM_TYPE_ACCESSORY = ItemType.ACCCESSORY;
  static const ItemType ITEM_TYPE_AMULET = ItemType.AMULET;
  static const ItemType ITEM_TYPE_OFFHAND = ItemType.OFF_HAND;
  static const ItemType ITEM_TYPE_BODY = ItemType.BODY;
  static const ItemType ITEM_TYPE_WEAPON = ItemType.WEAPON;
  static const ItemType ITEM_TYPE_FEET = ItemType.FEET;
  static const ItemType ITEM_TYPE_RING = ItemType.RING;

  static List<Version> versions;
  static Version version;
  static Character character;

  static void init() async {
    versions = await Version.getVersions(Client());
    version = versions.last;
  }

  String get borderName => character?.charClass?.id ?? 'default';
}
