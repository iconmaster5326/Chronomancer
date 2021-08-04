import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/about_dialog/about_dialog.dart';
import 'package:chronomancer/components/changelog_dialog/changelog_dialog.dart';
import 'package:chronomancer/components/char_sel/char_sel.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/equip_dialog/equip_dialog.dart';
import 'package:chronomancer/components/equip_slot/equip_slot.dart';
import 'package:chronomancer/components/export_dialog/export_dialog.dart';
import 'package:chronomancer/components/import_dialog/import_dialog.dart';
import 'package:chronomancer/components/item_editor/enchant_edit_dialog/enchant_edit_dialog.dart';
import 'package:chronomancer/components/item_editor/enchant_select_dialog/enchant_select_dialog.dart';
import 'package:chronomancer/components/item_editor/gem_dialog/gem_dialog.dart';
import 'package:chronomancer/components/item_editor/item_editor.dart';
import 'package:chronomancer/components/item_editor/socket_config_dialog/socket_config_dialog.dart';
import 'package:chronomancer/components/reset_dialog/reset_dialog.dart';
import 'package:chronomancer/components/skill_tree/skill_dialog/skill_dialog.dart';
import 'package:chronomancer/components/skill_tree/skill_tree.dart';
import 'package:chronomancer/components/skill_tree_tab/skill_tree_tab.dart';
import 'package:chronomancer/components/tooltips/enchant/enchant_tooltip.dart';
import 'package:chronomancer/components/tooltips/gem/gem_tooltip.dart';
import 'package:chronomancer/components/tooltips/item/item_tooltip.dart';
import 'package:chronomancer/components/tooltips/skill/skill_tooltip.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/skill.dart';
import 'package:chronomancer/version.dart';
import 'package:chronomancer/util.dart';
import 'package:http/http.dart';
import 'dart:html' as html;

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
    SkillTooltipComponent,
    GemTooltipComponent,
    AboutDialogComponent,
    ChangelogDialogComponent,
    ExportDialogComponent,
    ImportDialogComponent,
    ResetDialogComponent,
  ],
)
class ChronomancerComponent extends CommonComponent {
  static const AUTOSAVE_INTERVAL = 30;
  static const AUTOSAVE_STORAGE_KEY = 'chronomancerAutosave';
  static const BUILD_QUERY_PARAMETER = 'build';

  static const ITEM_TYPE_HEAD = ItemType.HEAD;
  static const ITEM_TYPE_ACCESSORY = ItemType.ACCCESSORY;
  static const ITEM_TYPE_AMULET = ItemType.AMULET;
  static const ITEM_TYPE_OFFHAND = ItemType.OFF_HAND;
  static const ITEM_TYPE_BODY = ItemType.BODY;
  static const ITEM_TYPE_WEAPON = ItemType.WEAPON;
  static const ITEM_TYPE_FEET = ItemType.FEET;
  static const ITEM_TYPE_RING = ItemType.RING;

  static List<Version> versions;
  static Version version;
  static Character character;
  static bool respeccing = false;

  static void init() async {
    versions = await Version.getVersions(Client());
    version = versions.last;

    if (Uri.base.queryParameters.containsKey(BUILD_QUERY_PARAMETER)) {
      try {
        character = Character.fromJSON(
            versions,
            json.decode(utf8.decode(base64
                .decode(Uri.base.queryParameters[BUILD_QUERY_PARAMETER]))));
        version = character.charClass.version;
      } on dynamic {
        html.window.alert('Bad build specified in the build link!');
        character = null;
        version = versions.last;
      }
    } else if (html.window.localStorage.containsKey(AUTOSAVE_STORAGE_KEY)) {
      character = Character.fromJSON(versions,
          json.decode(html.window.localStorage[AUTOSAVE_STORAGE_KEY]));
      version = character.charClass.version;
    }
  }

  final NgZone _zone;
  ChronomancerComponent(this._zone) {
    _zone.runOutsideAngular(() {
      html.window.onBeforeUnload.listen((event) {
        html.window.localStorage[AUTOSAVE_STORAGE_KEY] =
            json.encode(character.asJSON);
      });

      Timer.periodic(Duration(seconds: AUTOSAVE_INTERVAL), (timer) {
        if (character != null) {
          html.window.localStorage[AUTOSAVE_STORAGE_KEY] =
              json.encode(character.asJSON);
        }
      });
    });
  }

  String get borderName => character?.charClass?.id ?? 'default';
  String get skillPointsDisplay =>
      SkillTreeComponent.currentTree == Skill.TREE_MASTERY
          ? 'Mastery Points: ${character.masteryPointsSpent}'
          : 'Skill Points: ${character.pointsSpent} / ${character.level}';

  void setVersion(Version v) {
    if (v != version) {
      if (character == null) {
        version = v;
      } else {
        ResetDialogComponent.INSTANCE.newVersion = v;
        ResetDialogComponent.INSTANCE.show();
      }
    }
  }

  void showAboutDialog() {
    AboutDialogComponent.INSTANCE.show();
  }

  void showChangelogDialog() {
    ChangelogDialogComponent.INSTANCE.show();
  }

  void importBuild() async {
    try {
      character = Character.fromJSON(versions,
          json.decode(utf8.decode(base64.decode(await readClipboard()))));
      html.window.alert('Build imported from clipbaord.');
    } on dynamic {
      ImportDialogComponent.INSTANCE.show();
    }
  }

  void exportBuild() async {
    var charJSON = character.asJSON;
    var b64 = base64.encode(utf8.encode(json.encode(charJSON)));
    try {
      await writeClipboard(b64);
    } on dynamic {
      // do nothing
    }

    ExportDialogComponent.INSTANCE.title = 'Export Build';
    ExportDialogComponent.INSTANCE.desc =
        'Your build has been copied to the clipboard!';
    ExportDialogComponent.INSTANCE.exportedText = b64;
    ExportDialogComponent.INSTANCE.show();
  }

  void linkBuild() async {
    var charJSON = character.asJSON;
    var b64 = base64.encode(utf8.encode(json.encode(charJSON)));
    var uri = Uri.base.replace(queryParameters: {
      BUILD_QUERY_PARAMETER: b64,
    });
    try {
      await writeClipboard(uri.toString());
    } on dynamic {
      // do nothing
    }

    ExportDialogComponent.INSTANCE.title = 'Get Link to Build';
    ExportDialogComponent.INSTANCE.desc =
        'A link to your build has been copied to the clipboard!';
    ExportDialogComponent.INSTANCE.exportedText = uri.toString();
    ExportDialogComponent.INSTANCE.show();
  }

  int get minLevel => character.equipment.values
      .map((item) => item.item.minLevel)
      .followedBy([character.pointsSpent]).max;
  void onSetLevel(html.InputElement levelSpinner) {
    if (levelSpinner.valueAsNumber.isNaN) return;
    character.level =
        levelSpinner.valueAsNumber.toInt().clamp(minLevel, Character.MAX_LEVEL);
    for (var item in character.equipment.values) {
      item.level = min(item.level, character.level);
    }
    levelSpinner.valueAsNumber = character.level;
  }

  void resetCharacter() {
    if (character != null) {
      ResetDialogComponent.INSTANCE.show();
    }
  }
}
