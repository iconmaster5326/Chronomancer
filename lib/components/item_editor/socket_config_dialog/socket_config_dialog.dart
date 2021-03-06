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

    if (source == GemSource.INNATE) {
      item.gems
          .insertAll(0, shapes.map((shape) => GemSocket(item, source, shape)));
    } else {
      item.gems.addAll(shapes.map((shape) => GemSocket(item, source, shape)));
    }
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
}
