import 'package:angular/angular.dart';
import 'package:chronomancer/components/char_sel/char_sel.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/equip_dialog/equip_dialog.dart';
import 'package:chronomancer/components/equip_slot/equip_slot.dart';
import 'package:chronomancer/components/item_editor/enchant_edit_dialog/enchant_edit_dialog.dart';
import 'package:chronomancer/components/item_editor/enchant_select_dialog/enchant_select_dialog.dart';
import 'package:chronomancer/components/item_editor/gem_dialog/gem_dialog.dart';
import 'package:chronomancer/components/item_editor/item_editor.dart';
import 'package:chronomancer/components/item_editor/socket_config_dialog/socket_config_dialog.dart';
import 'package:chronomancer/components/skill_tree/skill_dialog/skill_dialog.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/components/skill_tree_tab/skill_tree_tab.dart';
import 'package:chronomancer/components/tooltips/enchant/enchant_tooltip.dart';
import 'package:chronomancer/components/tooltips/item/item_tooltip.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/version.dart';
import 'package:http/http.dart';

@Component(
  selector: 'chronomancer',
  styleUrls: ['chronomancer.css'],
  templateUrl: 'chronomancer.html',
  directives: [
    coreDirectives,
    InitDirective,
    CharSelCompoment,
    EquipSlotComponent,
    EquipDialogComponent,
    SkillTreeComponent,
    SkillTreeTabComponent,
    SkillDialogComponent,
    ItemEditorComponent,
    SocketConfigDialogComponent,
    GemDialogComponent,
    EnchantSelectDialogComponent,
    EnchantEditDialogComponent,
    ItemTooltipComponent,
    EnchantTooltipComponent,
  ],
)
class ChronomancerComponent extends CommonComponent {
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
  static bool respeccing = false;

  static void init() async {
    versions = await Version.getVersions(Client());
    version = versions.last;
  }

  String get borderName => character?.charClass?.id ?? 'default';
  String get skillPointsDisplay =>
      SkillTreeComponent.currentTree == Skill.TREE_MASTERY
          ? 'Mastery Points: ${character.masteryPointsSpent}'
          : 'Skill Points: ${character.pointsSpent} / ${character.level}';

  void setVersion(Version v) {
    if (v != version) {
      version = v;
      character = null;
    }
  }
}
