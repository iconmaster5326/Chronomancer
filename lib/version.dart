import 'dart:convert';
import 'package:http/http.dart';

import 'class.dart';
import 'enchant.dart';
import 'gem.dart';
import 'item.dart';
import 'skill.dart';

class Version {
  String name;
  List<CharClass> classes;
  List<Item> items;
  List<Enchant> enchants;
  List<Skill> skills;
  List<Gem> gems;
  Map<CharClass, Map<ItemType, Map<EnchantType, List<Enchant>>>> enchantPool;
  List rawDroppedRuneData;

  Version(this.name);

  static Future<Version> fromName(Client http, String name) async {
    var version = Version(name);
    version.classes = await CharClass.getClassList(version, http);
    version.items = await Item.getItemList(version, http);
    version.rawDroppedRuneData =
        await Enchant.getRawDroppedRuneData(version, http);
    version.enchants = await Enchant.getEnchantList(version, http);
    version.skills = await Skill.getSkillList(version, http);
    version.gems = await Gem.getGemList(version, http);

    for (var item in version.items) {
      item.finalize(version);
    }
    for (var enchant in version.enchants) {
      enchant.finalize(version);
    }
    for (var skill in version.skills) {
      skill.finalize(version);
    }
    for (var gem in version.gems) {
      gem.finalize(version);
    }

    version.enchantPool = await Enchant.getEnchantPool(version, http);

    version.rawDroppedRuneData = null;
    return version;
  }

  static Future<List<Version>> getVersions(Client http) async {
    final response = await http.get('assets/json/patches.json');
    return Stream.fromIterable(json.decode(response.body) as List)
        .asyncMap((v) => Version.fromName(http, v))
        .toList();
  }

  CharClass classWithName(String name) {
    for (var charClass in classes) {
      if (charClass.name == name) {
        return charClass;
      }
    }
    return null;
  }
}
