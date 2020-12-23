import 'dart:html';

import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'package:chronomancer/components/item_editor/gem_dialog/gem_dialog.dart';
import 'package:chronomancer/components/item_editor/item_editor.dart';
import 'package:chronomancer/components/slot/slot.dart';
import 'package:chronomancer/components/tooltips/gem/gem_tooltip.dart';
import 'package:chronomancer/item.dart';

@Component(
  selector: 'gem-socket',
  styleUrls: ['gem_socket.css'],
  templateUrl: 'gem_socket.html',
  directives: [coreDirectives],
)
class GemSocketComponent extends CommonComponent {
  static const int SOCKET_BACK_SIZE = 16;

  @Input()
  GemSocket socket;

  int get _itemX => socket.gem.id % ITEM_ICONS_PER_ROW;
  int get _itemY => socket.gem.id ~/ ITEM_ICONS_PER_ROW;

  String get socketBackgroundPos =>
      '${-socket.source.index * SOCKET_BACK_SIZE}px ${-socket.shape.index * SOCKET_BACK_SIZE}px';
  String get gemBackground => socket.gem == null
      ? ''
      : 'url("assets/images/items/${ChronomancerComponent.version.name}.png") ${-_itemX * ITEM_ICON_SIZE - ITEM_ICON_OFFSET}px ${-_itemY * ITEM_ICON_SIZE - ITEM_ICON_OFFSET}px';
  String get prongDisplay => socket.gem == null ? 'none' : 'inline-block';

  void onClick() {
    if (socket.gem == null) {
      GemDialogComponent.INSTANCE.socket = socket;
      GemDialogComponent.INSTANCE.show();
    }
  }

  void onRightClick(MouseEvent event) {
    event.preventDefault();

    if (event.shiftKey || event.ctrlKey) {
      socket.gem = null;
    } else {
      GemDialogComponent.INSTANCE.socket = socket;
      GemDialogComponent.INSTANCE.show();
    }
  }

  void onHoverIconBegin() {
    GemTooltipComponent.INSTANCE.item = ItemEditorComponent.editing;
    GemTooltipComponent.INSTANCE.gem = socket.gem;
  }

  void onHoverIconEnd() {
    GemTooltipComponent.INSTANCE.item = null;
    GemTooltipComponent.INSTANCE.gem = null;
  }
}
