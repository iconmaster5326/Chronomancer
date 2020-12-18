import 'package:angular/angular.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/components/chronomancer/chronomancer.dart';
import 'package:chronomancer/components/component_utils.dart';

@Component(
  selector: 'skill-tree-tab',
  styleUrls: ['skill_tree_tab.css'],
  templateUrl: 'skill_tree_tab.html',
  directives: [coreDirectives],
)
class SkillTreeTabComponent extends CommonComponent {
  static const int SKILL_TAB_ICON_SIZE = 22;

  @Input()
  int tree;
  bool hovering = false;

  CharClass get charClass => ChronomancerComponent.character.charClass;

  String get blendColor {
    if (hovering) {
      return 'rgba(255,255,255,0.5)';
    }
    if (tree == ChronomancerComponent.currentTree) {
      return 'rgba(0,0,0,0)';
    }
    return 'rgba(0,0,0,0.5)';
  }
  String get background =>
      'linear-gradient($blendColor,$blendColor), url("assets/images/skill_slots.png") -24px 0px, url("assets/images/skill_tree_tabs/${charClass.id}.png") ${-(tree * SKILL_TAB_ICON_SIZE - 1)}px 0px';
  
  void onClick() {
    ChronomancerComponent.currentTree = tree;
  }
}
