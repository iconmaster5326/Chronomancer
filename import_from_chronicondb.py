import argparse
import os
import json
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("cdb", type=str, help="the path to the root of ChronomancerDB")
parser.add_argument(
    "versions",
    type=str,
    nargs="*",
    help="the versions to import (default: all versions in ChronomancerDB)",
)
args = parser.parse_args()

chronomancer_path = os.path.join("web", "assets", "json")
cdb_path = os.path.join(args.cdb, "src", "engine", "data")

cdb_versions = json.load(open(os.path.join(cdb_path, "patches.json")))
chronomancer_versions = json.load(open(os.path.join(chronomancer_path, "patches.json")))

if args.versions:
    for version in args.versions:
        if version not in cdb_versions:
            parser.error("version %s is not in ChronomancerDB" % version)
    cdb_versions = [v for v in cdb_versions if v in args.versions]


def is_mastery(skill):
    return skill["tree"] == "Mastery"


def backfill_masteries(version):
    # some ChronomancerDB extracts are missing mastery data entirely;
    # fall back to the masteries of the latest version that has them
    skills_path = os.path.join(chronomancer_path, version, "skills.json")
    skills = json.load(open(skills_path))
    if any(is_mastery(skill) for skill in skills):
        return

    older_versions = chronomancer_versions[: chronomancer_versions.index(version)]
    for other_version in reversed(older_versions):
        other_skills = json.load(
            open(os.path.join(chronomancer_path, other_version, "skills.json"))
        )
        masteries = [skill for skill in other_skills if is_mastery(skill)]
        if masteries:
            skills.extend(masteries)
            json.dump(skills, open(skills_path, "w"), indent=2)
            print(
                "warning: version %s has no masteries; copied them from version %s"
                % (version, other_version)
            )
            return

    print("warning: version %s has no masteries!" % version)


for version in cdb_versions:
    version_is_new = not os.path.exists(os.path.join(chronomancer_path, version))

    if version_is_new:
        last_version = chronomancer_versions[-1]
        os.makedirs(os.path.join(chronomancer_path, version), exist_ok=True)

    for filename in ["enchants", "enchantsPool", "items", "sets", "skills"]:
        json_filename = filename + ".json"
        shutil.copy2(
            os.path.join(cdb_path, version, "extracts", json_filename),
            os.path.join(chronomancer_path, version, json_filename),
        )

    if version_is_new:
        for filename in ["classes", "droppedRunes"]:
            json_filename = filename + ".json"
            shutil.copy2(
                os.path.join(chronomancer_path, last_version, json_filename),
                os.path.join(chronomancer_path, version, json_filename),
            )
        chronomancer_versions.append(version)
        json.dump(
            chronomancer_versions,
            open(os.path.join(chronomancer_path, "patches.json"), "w"),
            indent=2,
        )
        print("new version %s added. Ensure that files are correct." % version)

    backfill_masteries(version)
