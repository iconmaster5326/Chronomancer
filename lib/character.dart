import 'package:chronomancer/class.dart';

import 'item.dart';

class Character {
  CharClass charClass;
  Map<ItemType, ItemStack> equipment = <ItemType, ItemStack>{};

  Character(this.charClass);
}
