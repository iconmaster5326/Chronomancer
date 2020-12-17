import 'package:angular/angular.dart';
import 'package:chronomancer/components/char_sel/char_sel.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/version.dart';
import 'package:http/http.dart';

// AngularDart info: https://angulardart.dev
// Components info: https://angulardart.dev/components

@Component(
  selector: 'chronomancer',
  styleUrls: ['chronomancer.css'],
  templateUrl: 'chronomancer.html',
  directives: [NgFor, NgIf, CharSelCompoment],
)
class ChronomancerComponent {
  static List<Version> versions;
  static Version version;
  static Character character;

  static void init() async {
    versions = await Version.getVersions(Client());
    version = versions.last;
  }
}
