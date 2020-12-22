import 'dart:convert';
import 'package:http/http.dart';

import 'enchant.dart';
import 'gem.dart';
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

abstract class ItemData {
  int get id;
  String get name;
  ItemType get type;
  ItemRarity get rarity;
  Iterable<EnchantData> get fixedEnchantData;
  Iterable<List<EnchantType>> get floatingEnchantData;
  CharClass get requiresClass;
  String get typeName;
  bool get empowerable;
  bool get empowered;
  bool get augmented;
  Iterable<GemSocket> get gems;
}

class _BaseEnchant extends EnchantStack {
  _BaseEnchant(Enchant enchant) : super(EnchantStackSource.BASE, enchant, null);
}

class _FixedEnchant extends EnchantStack {
  _FixedEnchant(Enchant enchant)
      : super(EnchantStackSource.FIXED, enchant, null);
}

class Item implements ItemData {
  @override
  int id;
  @override
  String name, typeName;
  @override
  ItemType type;
  @override
  ItemRarity rarity;
  @override
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
        typeName = j['type'],
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

  List<ItemRarity> get possibleRarities {
    switch (rarity) {
      case ItemRarity.ORDINARY:
        return [ItemRarity.ORDINARY, ItemRarity.ENCHANTED, ItemRarity.RARE];
      case ItemRarity.ENCHANTED:
        return [ItemRarity.ENCHANTED, ItemRarity.RARE];
      default:
        return [rarity];
    }
  }

  @override
  Iterable<EnchantData> get fixedEnchantData => baseEnchants
      .map<EnchantData>((e) => _BaseEnchant(e))
      .followedBy(fixedEnchants.map<EnchantData>((e) => _FixedEnchant(e)));
  @override
  Iterable<List<EnchantType>> get floatingEnchantData =>
      ItemStack.RARITY_BASED_ENCHANT_SLOTS[type][rarity];
  @override
  bool get empowerable =>
      rarity == ItemRarity.UNIQUE || rarity == ItemRarity.LEGENDARY;
  @override
  bool get empowered => false;
  @override
  bool get augmented => false;

  @override
  Iterable<GemSocket> get gems => id == ItemStack.WEYRICKS_FINERY_ID
      ? [
          GemSocket(null, GemSource.ENCHANT, GemShape.SPHERE),
          GemSocket(null, GemSource.ENCHANT, GemShape.CUBE),
          GemSocket(null, GemSource.ENCHANT, GemShape.STAR)
        ]
      : [];
}

enum GemSource {
  INNATE,
  ENCHANT,
  PRISMATIC,
}

class GemSocket {
  ItemStack item;
  GemSource source;
  GemShape shape;
  Gem gem;

  GemSocket(this.item, this.source, this.shape, [this.gem]);
  EnchantStack get enchant => EnchantStack(
      EnchantStackSource.FLOATING,
      gem.enchants[item.type],
      gem.enchants[item.type].ranges[ItemRarity.values[gem.quality.index]].max);
}

class ItemStack implements ItemData {
  Item item;
  @override
  ItemRarity rarity;
  List<EnchantStack> enchants = [];
  @override
  List<GemSocket> gems = [];
  @override
  bool empowered = true;

  static int WEYRICKS_FINERY_ID = 713;

  static const INNATE_GEM_SOCKET_CONFIGURATIONS = {
    ItemType.ACCCESSORY: [
      [GemShape.STAR],
      [GemShape.CUBE],
      [GemShape.SPHERE],
    ],
    ItemType.AMULET: [
      [GemShape.STAR],
      [GemShape.CUBE, GemShape.CUBE],
      [GemShape.CUBE, GemShape.SPHERE],
      [GemShape.SPHERE, GemShape.SPHERE],
    ],
    ItemType.BODY: [
      [GemShape.STAR, GemShape.STAR],
      [GemShape.STAR, GemShape.CUBE, GemShape.CUBE],
      [GemShape.STAR, GemShape.CUBE, GemShape.SPHERE],
      [GemShape.STAR, GemShape.SPHERE, GemShape.SPHERE],
      [GemShape.CUBE, GemShape.CUBE, GemShape.CUBE],
      [GemShape.CUBE, GemShape.CUBE, GemShape.SPHERE],
      [GemShape.CUBE, GemShape.SPHERE, GemShape.SPHERE],
      [GemShape.SPHERE, GemShape.SPHERE, GemShape.SPHERE],
    ],
    ItemType.FEET: [
      [GemShape.STAR],
      [GemShape.CUBE],
      [GemShape.SPHERE],
    ],
    ItemType.HEAD: [
      [GemShape.STAR],
      [GemShape.CUBE, GemShape.CUBE],
      [GemShape.CUBE, GemShape.SPHERE],
      [GemShape.SPHERE, GemShape.SPHERE],
    ],
    ItemType.OFF_HAND: [
      [GemShape.STAR],
      [GemShape.CUBE],
      [GemShape.SPHERE],
    ],
    ItemType.RING: [
      [GemShape.STAR],
      [GemShape.CUBE],
      [GemShape.SPHERE],
    ],
    ItemType.WEAPON: [
      [GemShape.STAR],
      [GemShape.CUBE, GemShape.CUBE],
      [GemShape.CUBE, GemShape.SPHERE],
      [GemShape.SPHERE, GemShape.SPHERE],
    ],
  };

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
    enchants.addAll(item.baseEnchants.map((e) => EnchantStack(
        EnchantStackSource.BASE,
        e,
        e.ranges[effectiveRarity].maxGreaterAugmented)));
    enchants.addAll(item.fixedEnchants.map((e) => EnchantStack(
        EnchantStackSource.FIXED,
        e,
        e.ranges[effectiveRarity].maxGreaterAugmented)));
    enchants.add(null); // rune slot
    regenerateMutableEnchants();

    if (item.id == WEYRICKS_FINERY_ID) {
      gems.addAll([
        GemSocket(this, GemSource.ENCHANT, GemShape.SPHERE),
        GemSocket(this, GemSource.ENCHANT, GemShape.CUBE),
        GemSocket(this, GemSource.ENCHANT, GemShape.STAR)
      ]);
    }
  }

  bool mutableEnchant(int slot) =>
      slot >= item.baseEnchants.length + item.fixedEnchants.length;
  int get runeEnchantSlot =>
      item.baseEnchants.length + item.fixedEnchants.length;
  bool runeEnchant(int slot) => slot == runeEnchantSlot;
  List<EnchantType> enchantTypesForSlot(int slot) => runeEnchant(slot)
      ? [EnchantType.LEGENDARY]
      : mutableEnchant(slot)
          ? RARITY_BASED_ENCHANT_SLOTS[item.type][rarity]
              [slot - item.baseEnchants.length - item.fixedEnchants.length - 1]
          : [enchants[slot].type];
  @override
  bool get empowerable =>
      rarity == ItemRarity.UNIQUE || rarity == ItemRarity.LEGENDARY;
  ItemRarity get effectiveRarity =>
      empowered ? ItemRarity.TRUE_LEGENDARY : rarity;

  void regenerateMutableEnchants() {
    enchants = enchants.sublist(0, runeEnchantSlot + 1);
    enchants.addAll(List<EnchantStack>.filled(
        RARITY_BASED_ENCHANT_SLOTS[item.type][rarity].length, null));
  }

  void clampEnchantValues() {
    for (var enchant in enchants) {
      if (enchant != null) {
        var range = enchant.enchant.ranges[effectiveRarity];
        enchant.value =
            enchant.value.clamp(range.min, range.maxGreaterAugmented);
      }
    }
  }

  EnchantStackSource sourceOf(int slot) {
    if (slot < item.baseEnchants.length) {
      return EnchantStackSource.BASE;
    } else if (slot < item.baseEnchants.length + item.fixedEnchants.length) {
      return EnchantStackSource.FIXED;
    } else if (slot == runeEnchantSlot) {
      return EnchantStackSource.RUNE;
    } else {
      return EnchantStackSource.FLOATING;
    }
  }

  @override
  int get id => item.id;
  @override
  String get name => item.name;
  @override
  ItemType get type => item.type;
  @override
  CharClass get requiresClass => item.requiresClass;
  @override
  Iterable<EnchantData> get fixedEnchantData =>
      enchants.where((e) => e != null);
  @override
  Iterable<List<EnchantType>> get floatingEnchantData => Range(
          0, enchants.length - 1)
      .where((slot) =>
          mutableEnchant(slot) && !runeEnchant(slot) && enchants[slot] == null)
      .map((slot) => enchantTypesForSlot(slot));
  @override
  String get typeName => item.typeName;
  @override
  bool get augmented =>
      enchants.any((e) => e != null && e.value > e.enchant.ranges[rarity].max);

  @Deprecated('use type instead.')
  ItemType get slot => item.type;
}
