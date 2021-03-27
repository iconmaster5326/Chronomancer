# this script takes assets from ChroniconDB and stitches it together into sprite sheets.

import argparse
import os
import PIL.Image
import math
import json

SHEET_WIDTH = 32
ITEM_ICON_SIZE = 32
SKILL_ICON_SIZE = 22
MASTERY_UUID_OFFSET = 100000

parser = argparse.ArgumentParser()
parser.add_argument("cdb", type=str, help="the path to the root of ChronomancerDB")
args = parser.parse_args()

item_images_path = os.path.join(
    args.cdb, "public", "assets", "images", "game", "items", "all"
)
skill_images_paths = (
    os.path.join(args.cdb, "public", "assets", "images", "game", "skills", "skills"),
    os.path.join(args.cdb, "public", "assets", "images", "game", "skills", "masteries"),
)

json_path = os.path.join(args.cdb, "src", "engine", "data")
versions_json = json.load(open(os.path.join(json_path, "patches.json")))

for version in versions_json:
    version_json_path = os.path.join(json_path, version, "extracts")

    # make item sheet
    items_json = json.load(open(os.path.join(version_json_path, "items.json")))
    n_item_uuids = max(*[x["uuid"] for x in items_json]) + 1
    stitched_items = PIL.Image.new(
        "RGBA",
        size=(
            ITEM_ICON_SIZE * SHEET_WIDTH,
            ITEM_ICON_SIZE * math.ceil(n_item_uuids / SHEET_WIDTH),
        ),
        color=None,
    )

    for item in sorted(items_json, key=lambda item: item["uuid"]):
        if "icon" in item and item["icon"]:
            x = item["uuid"] % SHEET_WIDTH
            y = item["uuid"] // SHEET_WIDTH

            item_image = PIL.Image.open(
                os.path.join(item_images_path, item["icon"] + ".png")
            )
            xdiff = ITEM_ICON_SIZE - item_image.size[0]
            ydiff = ITEM_ICON_SIZE - item_image.size[1]
            assert xdiff >= 0 and ydiff >= 0
            stitched_items.paste(
                item_image,
                (x * ITEM_ICON_SIZE + xdiff // 2, y * ITEM_ICON_SIZE + ydiff // 2),
            )
            item_image.close()
        else:
            print("warning: item %s has no icon!" % item["uuid"])

    stitched_items.save(
        os.path.join("web", "assets", "images", "items", version + ".png")
    )
    stitched_items.close()

    # make skills sheet
    skills_json = json.load(open(os.path.join(version_json_path, "skills.json")))
    n_non_mastery_uuids = (
        max(*[x["uuid"] for x in skills_json if x["uuid"] < MASTERY_UUID_OFFSET]) + 1
    )
    n_mastery_uuids = (
        max(*[x["uuid"] for x in skills_json if x["uuid"] >= MASTERY_UUID_OFFSET])
        - MASTERY_UUID_OFFSET
        + 1
    )
    stitched_skills = PIL.Image.new(
        "RGBA",
        size=(
            SKILL_ICON_SIZE * SHEET_WIDTH,
            SKILL_ICON_SIZE
            * math.ceil((n_non_mastery_uuids + n_mastery_uuids) / SHEET_WIDTH),
        ),
        color=None,
    )

    for skill in sorted(skills_json, key=lambda item: item["uuid"]):
        if "icon" in skill and skill["icon"]:
            effective_id = skill["uuid"] if skill["uuid"] < MASTERY_UUID_OFFSET else skill["uuid"] - MASTERY_UUID_OFFSET + n_non_mastery_uuids
            x = effective_id % SHEET_WIDTH
            y = effective_id // SHEET_WIDTH
            skill_image = None

            for path in skill_images_paths:
                skill_image_path = os.path.join(path, skill["icon"] + ".png")
                if os.path.exists(skill_image_path):
                    skill_image = PIL.Image.open(skill_image_path)
                    break

            assert skill_image is not None
            stitched_skills.paste(
                skill_image,
                (x * SKILL_ICON_SIZE, y * SKILL_ICON_SIZE),
            )
            skill_image.close()
        else:
            print("warning: skill %s has no icon!" % skill["uuid"])

    stitched_skills.save(
        os.path.join("web", "assets", "images", "skills", version + ".png")
    )
    stitched_skills.close()
