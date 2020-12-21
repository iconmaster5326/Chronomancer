import json

enchants_json = json.load(open("web/assets/json/1.10.8/enchants.json"))
enchants = {}
for enchant_json in enchants_json:
    enchants[enchant_json["name"]] = enchant_json["uuid"]

text_to_cats = {
    "Anything": [
        "Accessory",
        "Amulet",
        "Ring",
        "Weapon",
        "Offhand",
        "Helmet",
        "Boots",
        "Armor",
    ],
    "Accessory, Amulet, Ring": ["Accessory", "Amulet", "Ring"],
    "Weapon, Offhand": ["Weapon", "Offhand"],
    "Armor, Boots, Helmet": ["Helmet", "Boots", "Armor"],
}

char_class = None
result = []
for line in open("runes.txt").readlines():
    if line.startswith("#"):
        char_class = line[1:].strip()
    else:
        parts = line.strip().split("\t")
        result.append(
            {
                "uuid": enchants[parts[0]],
                "class": char_class,
                "categories": text_to_cats[parts[1]],
            }
        )

for version in json.load(open("web/assets/json/patches.json")):
    json.dump(result, open("web/assets/json/%s/droppedRunes.json" % version, "w"), indent=2)
