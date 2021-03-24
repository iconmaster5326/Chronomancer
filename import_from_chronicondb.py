import argparse
import os
import json
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("cdb", type=str, help="the path to the root of ChronomancerDB")
args = parser.parse_args()

chronomancer_path = os.path.join("web", "assets", "json")
cdb_path = os.path.join(args.cdb, "src", "engine", "data")

cdb_versions = json.load(open(os.path.join(cdb_path, "patches.json")))
chronomancer_versions = json.load(open(os.path.join(chronomancer_path, "patches.json")))

for version in cdb_versions:
    if os.path.exists(os.path.join(chronomancer_path, version)):
        for filename in ["enchants", "enchantsPool", "items", "sets", "skills"]:
            json_filename = filename + ".json"
            shutil.copy2(
                os.path.join(cdb_path, version, "extracts", json_filename),
                os.path.join(chronomancer_path, version, json_filename),
            )
    else:
        last_version = chronomancer_versions[-1]
        shutil.copy2(
            os.path.join(cdb_path, version, "extracts"),
            os.path.join(chronomancer_path, version),
        )
        for filename in ["classes", "droppedRunes"]:
            json_filename = filename + ".json"
            shutil.copy2(
                os.path.join(chronomancer_path, last_version, json_filename),
                os.path.join(chronomancer_path, version, json_filename),
            )
            chronomancer_versions += version
            json.dump(
                chronomancer_versions,
                open(os.path.join(chronomancer_path, "patches.json"), "w"),
                indent=2,
            )
            print("new version %s added. Ensure that files are correct." % version)
