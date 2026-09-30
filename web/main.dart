import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';
import 'main.template.dart' as self;

import 'package:chronomancer/components/chronomancer/chronomancer.template.dart' as ng;

void main() async {
  UiScale.enable();
  await ChronomancerComponent.init();
  runApp(ng.createChronomancerComponentFactory());
}
