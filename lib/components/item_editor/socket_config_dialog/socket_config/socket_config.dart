import 'package:angular/angular.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/gem_socket/gem_socket.dart';
import 'package:chronomancer/components/item_editor/socket_config_dialog/socket_config_dialog.dart';
import 'package:chronomancer/gem.dart';
import 'package:chronomancer/item.dart';
import 'package:chronomancer/util.dart';

@Component(
  selector: 'socket-config',
  styleUrls: ['socket_config.css'],
  templateUrl: 'socket_config.html',
  directives: [coreDirectives],
)
class SocketConfigComponent extends CommonComponent {
  @Input()
  GemSource source;
  @Input()
  List<GemShape> shapes;

  /// only used with the ring of marvellous gems
  @Input()
  int slot;

  String iconBackgroundPos(GemShape shape) =>
      '${-source.index * GemSocketComponent.SOCKET_BACK_SIZE}px ${-shape.index * GemSocketComponent.SOCKET_BACK_SIZE}px';
  bool get selected => SocketConfigDialogComponent.INSTANCE.item.gems
      .where((socket) => socket.source == source)
      .map((socket) => socket.shape)
      .equals(shapes);
}
