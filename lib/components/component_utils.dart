import 'package:angular/angular.dart' as angular;
import 'dart:js' as js;
import 'dart:async' as streams;
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:chronomancer/util.dart';

/// The UI is laid out at the game's native pixel size, so scale the whole
/// page up to fill larger windows.
class UiScale {
  // roughly the size of the character screen at a scale of 1
  static const int BASE_WIDTH = 1000, BASE_HEIGHT = 420;

  static num value = 1;

  static void apply() {
    var root = html.document.documentElement;
    value = math.max(
        1,
        math.min(root.clientWidth / BASE_WIDTH,
            html.window.innerHeight / BASE_HEIGHT));
    root.style.setProperty('zoom', value.toString());
  }

  static void enable() {
    apply();
    html.window.onResize.listen((_) => apply());
  }
}

/// Places a tooltip next to the mouse cursor, flipping it to the other side
/// of the cursor where it would otherwise run off the window.
class TooltipPlacement {
  static const int OFFSET = 8;

  html.Element element;
  // the mouse position, in window pixels
  num _mouseX = 0, _mouseY = 0;

  void onMouseMove(html.MouseEvent event) {
    _mouseX = event.client.x;
    _mouseY = event.client.y;
  }

  // mouse events and bounding rects are in window pixels, but CSS pixels are
  // scaled by the zoom
  num _place(num mouse, num size, num windowSize) {
    var offset = OFFSET * UiScale.value;
    var pos = mouse + offset;
    if (pos + size > windowSize) {
      pos = math.max(0, mouse - offset - size);
    }
    return pos / UiScale.value;
  }

  html.Rectangle get _size =>
      element?.getBoundingClientRect() ?? html.Rectangle(0, 0, 0, 0);
  html.Element get _window => html.document.documentElement;

  String get left => '${_place(_mouseX, _size.width, _window.clientWidth)}px';
  String get top => '${_place(_mouseY, _size.height, _window.clientHeight)}px';
}

class CommonComponent {
  void _enableTooltips(html.Element e) {
    js.context.callMethod(r'$', ['[data-toggle="tooltip"]', e]).callMethod(
        'tooltip', ['hide']);
    js.context.callMethod(r'$', ['[data-toggle="popover"]', e]).callMethod(
        'popover', ['hide']);

    js.context
        .callMethod(r'$', ['[data-toggle="tooltip"]', e]).callMethod('tooltip');
    js.context
        .callMethod(r'$', ['[data-toggle="popover"]', e]).callMethod('popover');
  }

  void enableTooltips(html.Element e) {
    _enableTooltips(e);
    html.MutationObserver((children, observer) {
      _enableTooltips(e);
    }).observe(e.parent, childList: true);
  }

  void _lockScrolling(html.Element e) {
    e.scrollTop = e.scrollHeight;
  }

  void enableScrollLock(html.Element e) {
    _lockScrolling(e);
    html.MutationObserver((children, observer) {
      _lockScrolling(e);
    }).observe(e.parent, childList: true, characterData: true, subtree: true);
  }
}

@angular.Directive(selector: '[init]')
class InitDirective implements angular.AfterContentInit {
  InitDirective() {
    stream = streamController.stream;
  }

  streams.StreamController streamController = streams.StreamController();

  @angular.Output('init')
  streams.Stream stream;

  @override
  void ngAfterContentInit() {
    streamController.add(null);
  }
}

class ModalComponent extends CommonComponent {
  html.Element element;
  bool open = false;

  void show() {
    js.context.callMethod(r'$', [element]).callMethod('modal', ['show']);
    open = true;
  }

  void hide() {
    js.context.callMethod(r'$', [element]).callMethod('modal', ['hide']);
  }

  void init(html.Element e) {
    element = e;
    js.context.callMethod(r'$', [element]).callMethod('on', [
      'hidden.bs.modal',
      js.allowInterop((e) {
        open = false;
      })
    ]);
  }
}

class ColoredText extends Pair<String, String> {
  ColoredText(String c, String t) : super(c, t);

  String get color => first;
  set color(String v) => first = v;
  String get text => second;
  set text(String v) => second = v;
}

void writeClipboard(String text) async {
  try {
    await html.window.navigator.clipboard.writeText(text);
  } on dynamic {
    html.TextAreaElement textArea = html.document.createElement('textarea');
    textArea.value = text;
    html.document.body.append(textArea);
    textArea.focus();
    textArea.select();
    html.document.execCommand('copy');
    textArea.remove();
  }
}

streams.Future<String> readClipboard() async {
  try {
    return await html.window.navigator.clipboard.readText();
  } on dynamic {
    html.TextAreaElement textArea = html.document.createElement('textarea');
    html.document.body.append(textArea);
    textArea.focus();
    textArea.select();
    html.document.execCommand('paste');
    var result = textArea.value;
    textArea.remove();
    return result;
  }
}
