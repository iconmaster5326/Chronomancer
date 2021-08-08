import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/socket_config_dialog/socket_config/socket_config.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'socket-config-dialog',
  styleUrls: ['socket_config_dialog.css'],
  templateUrl: 'socket_config_dialog.html',
  directives: [coreDirectives, InitDirective, SocketConfigComponent],
)
class SocketConfigDialogComponent extends ModalComponent {
  static GemSource SRC_INNATE = GemSource.INNATE;
  static GemSource SRC_ENCHANT = GemSource.ENCHANT;
  static GemSource SRC_PRISMATIC = GemSource.PRISMATIC;
  static SocketConfigDialogComponent INSTANCE;
  ItemStack item;

  @override
  void init(Element e) {
    super.init(e);
    INSTANCE = this;
  }

  void onSocketConfigSelected(GemSource source, List<GemShape> shapes) {
    item.gems.removeWhere((socket) => socket.source == source);
    var newSockets = shapes.map((shape) => GemSocket(item, source, shape));

    switch (source) {
      case GemSource.INNATE:
        item.gems.insertAll(0, newSockets);
        break;
      case GemSource.ENCHANT:
        var socketToInsert = item.gems.firstWhere(
            (s) => s.source == GemSource.PRISMATIC,
            orElse: () => null);
        if (socketToInsert == null) {
          item.gems.addAll(newSockets);
        } else {
          item.gems.insertAll(item.gems.indexOf(socketToInsert), newSockets);
        }
        break;
      case GemSource.PRISMATIC:
        item.gems.addAll(newSockets);
        break;
    }
  }

  void onMarvellousGemSocketConfigSelected(List<GemShape> shapes, int slot) {
    var gems = item.gems.where((i) => i.source == SRC_ENCHANT).toList()[slot];
    var gems_index = item.gems.indexOf(gems);
    item.gems[gems_index] = GemSocket(item, SRC_ENCHANT, shapes.first);
  }

  List<List<GemShape>> get innateConfigs => item == null
      ? <List<GemShape>>[]
      : [<GemShape>[]]
          .followedBy(ItemStack.INNATE_GEM_SOCKET_CONFIGURATIONS[item.slot])
          .toList();
  List<List<GemShape>> get prismaticConfigs => item == null
      ? <List<GemShape>>[]
      : [
          <GemShape>[],
          [GemShape.STAR],
          [GemShape.CUBE],
          [GemShape.SPHERE],
        ];
  List<List<GemShape>> get marvellousGemsConfigs =>
      ItemStack.RING_OF_MARVELLOUS_GEMS_SOCKET_CONFIGURATIONS;

  bool get isRingOfMarvellousGems =>
      item?.id == ItemStack.RING_OF_MARVELLOUS_GEMS_ID;
  bool get isWeyricksFinery => item?.id == ItemStack.WEYRICKS_FINERY_ID;
}
