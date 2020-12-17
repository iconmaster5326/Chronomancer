import 'package:angular/angular.dart';
import 'package:chronomancer/class.dart';

@Component(
  selector: 'char-sel',
  styleUrls: ['char_sel.css'],
  templateUrl: 'char_sel.html',
  directives: [],
)
class CharSelCompoment {
  @Input()
  CharClass charClass;
}
