import 'dart:html';

import 'package:angular/angular.dart' as angular;
import 'dart:js' as js;
import 'dart:async' as streams;
import 'dart:html' as html;

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
  Element element;
  bool open = false;

  void show() {
    js.context.callMethod(r'$', [element]).callMethod('modal', ['show']);
    open = true;
  }

  void hide() {
    js.context.callMethod(r'$', [element]).callMethod('modal', ['hide']);
  }

  void init(Element e) {
    element = e;
    js.context.callMethod(r'$', [element]).callMethod('on', [
      'hidden.bs.modal',
      js.allowInterop((e) {
        open = false;
      })
    ]);
  }
}

class ColoredText {
  String color, text;

  ColoredText(this.color, this.text);
}
