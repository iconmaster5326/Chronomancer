import 'dart:convert';
import 'package:http/http.dart';

import 'version.dart';
import 'class.dart';
import 'util.dart';

enum ItemType {
  RING,
  FEET,
  BODY,
  AMULET,
  ACCCESSORY,
  WEAPON,
  OFF_HAND,
  HEAD,
}

const Map<ItemType, String> ITEM_TYPE_TO_STRING = <ItemType, String>{
  ItemType.RING: 'Ring',
  ItemType.FEET: 'Boots',
  ItemType.BODY: 'Armor',
  ItemType.AMULET: 'Amulet',
  ItemType.ACCCESSORY: 'Accessory',
  ItemType.WEAPON: 'Weapon',
  ItemType.OFF_HAND: 'Offhand',
  ItemType.HEAD: 'Helmet',
};

enum ItemRarity {
  ORDINARY,
  ENCHANTED,
  RARE,
  UNIQUE,
  LEGENDARY,
  TRUE_LEGENDARY,
}

const Map<ItemRarity, String> ITEM_RARITY_TO_STRING = <ItemRarity, String>{
  ItemRarity.ORDINARY: 'Ordinary',
  ItemRarity.ENCHANTED: 'Enchanted',
  ItemRarity.RARE: 'Rare',
  ItemRarity.UNIQUE: 'Unique',
  ItemRarity.LEGENDARY: 'Legendary',
  ItemRarity.TRUE_LEGENDARY: 'True Legendary',
};

class Item {
  int id;
  String name;
  ItemType type;
  ItemRarity rarity;
  CharClass requiresClass;

  Item(this.id, this.name, this.type, this.rarity, this.requiresClass);

  Item.fromJSON(Version version, Map<String, dynamic> j)
      : this(
            j['uuid'],
            j['name'],
            ITEM_TYPE_TO_STRING.inverted[j['category']],
            ITEM_RARITY_TO_STRING.inverted[j['rarity']],
            version.classWithName(j['classRestriction']));

  static Future<List<Item>> getItemList(Version version, Client http) async {
    final response = await http.get('assets/json/${version.name}/items.json');
    return (json.decode(response.body) as List)
        .where((j) => ITEM_TYPE_TO_STRING.containsValue(j['category']))
        .map((j) => Item.fromJSON(version, j))
        .toList();
  }
}

class ItemStack {
  Item item;

  ItemStack(this.item);

  int get id => item.id;
  String get name => item.name;
  ItemType get slot => item.type;
  ItemRarity get rarity => item.rarity;
  CharClass get requiresClass => item.requiresClass;
}
