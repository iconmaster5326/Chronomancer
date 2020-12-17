import 'package:angular/angular.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';

@Component(
  selector: 'char-sel',
  styleUrls: ['char_sel.css'],
  templateUrl: 'char_sel.html',
  directives: [],
)
class CharSelCompoment {
  @Input()
  CharClass charClass;

  void onSelect() {
    ChronomancerComponent.character = Character(charClass);
  }
}
