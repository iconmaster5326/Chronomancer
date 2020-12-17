import 'package:angular/angular.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'main.template.dart' as self;

import 'package:chronomancer/components/chronomancer/chronomancer.template.dart' as ng;

void main() async {
  await ChronomancerComponent.init();
  runApp(ng.createChronomancerComponentFactory());
}
