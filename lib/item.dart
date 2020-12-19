import 'dart:convert';
import 'package:http/http.dart';

import 'enchant.dart';
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
  List<Enchant> baseEnchants, fixedEnchants;
  List<int> _rawBaseEnchants, _rawFixedEnchants;

  Item(this.id, this.name, this.type, this.rarity, this.requiresClass);

  Item.fromJSON(Version version, Map<String, dynamic> j)
      : id = j['uuid'],
        name = j['name'],
        type = ITEM_TYPE_TO_STRING.inverted[j['category']],
        rarity = ITEM_RARITY_TO_STRING.inverted[j['rarity']],
        requiresClass = version.classWithName(j['classRestriction']),
        _rawBaseEnchants = List<int>.from(j['baseEnchants']),
        _rawFixedEnchants = List<int>.from(j['fixedEnchants']);

  void finalize(Version version) {
    baseEnchants = _rawBaseEnchants
        .map((id) => version.enchants.firstWhere((e) => e.id == id))
        .toList();
    fixedEnchants = _rawFixedEnchants
        .map((id) => version.enchants.firstWhere((e) => e.id == id))
        .toList();
    _rawBaseEnchants = null;
    _rawFixedEnchants = null;
  }

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
  ItemRarity rarity;
  List<EnchantStack> enchants = [];

  static const RARITY_BASED_ENCHANT_SLOTS = {
    ItemType.HEAD: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
    },
    ItemType.ACCCESSORY: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
    },
    ItemType.OFF_HAND: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
      ],
    },
    ItemType.RING: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
    },
    ItemType.AMULET: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR],
        [EnchantType.EPIC],
      ],
    },
    ItemType.WEAPON: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
    },
    ItemType.BODY: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
    },
    ItemType.FEET: {
      ItemRarity.ORDINARY: <List<EnchantType>>[],
      ItemRarity.ENCHANTED: [
        [EnchantType.MINOR, EnchantType.MAJOR]
      ],
      ItemRarity.RARE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.UNIQUE: [
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
      ItemRarity.TRUE_LEGENDARY: [
        [EnchantType.MINOR],
        [EnchantType.MINOR],
        [EnchantType.MAJOR],
        [EnchantType.MAJOR, EnchantType.EPIC],
      ],
    },
  };

  ItemStack(this.item, [this.rarity]) {
    rarity = rarity ?? item.rarity;
    enchants.addAll(item.baseEnchants.map((e) => EnchantStack(e, 0)));
    enchants.addAll(item.fixedEnchants.map((e) => EnchantStack(e, 0)));
    enchants.addAll(List<EnchantStack>.filled(
        RARITY_BASED_ENCHANT_SLOTS[item.type][rarity].length, null));
  }

  bool mutableEnchant(int slot) =>
      slot >= item.baseEnchants.length + item.fixedEnchants.length;
  List<EnchantType> enchantTypesForSlot(int slot) => mutableEnchant(slot)
      ? RARITY_BASED_ENCHANT_SLOTS[item.type][rarity]
          [slot - item.baseEnchants.length - item.fixedEnchants.length]
      : [enchants[slot].type];

  int get id => item.id;
  String get name => item.name;
  ItemType get slot => item.type;
  CharClass get requiresClass => item.requiresClass;
}
