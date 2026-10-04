import 'package:chronomancer/artifact.dart';
import 'package:chronomancer/character.dart';
import 'package:chronomancer/class.dart';
import 'package:chronomancer/version.dart';
import 'package:test/test.dart';

Version testVersion({bool withArtifacts = true}) {
  var version = Version('1.60.0');
  version.classes = [
    CharClass(
        version, 'warden', 'Warden', ['a', 'b', 'c', 'd', 'm'], [], [], [], 3),
    CharClass(version, 'mechanist', 'Mechanist', ['a', 'b', 'c', 'd', 'm'], [],
        [], [], 5),
  ];
  version.skills = [];
  version.items = [];
  version.artifacts = withArtifacts
      ? [
          Artifact.fromJSON(version, {
            'uuid': '10002',
            'name': 'Magnetic Device',
            'class': 'Any Class',
            'type': 'Triangle',
            'description': '+AMOUNT% Pickup Radius.',
            'value': '50'
          }),
          Artifact.fromJSON(version, {
            'uuid': '10005',
            'name': 'Battle Lust',
            'class': 'Any Class',
            'type': 'Triangle',
            'description': 'Killstreaks last AMOUNT% longer.',
            'value': '30'
          }),
          Artifact.fromJSON(version, {
            'uuid': '10026',
            'name': "Companion's Calling",
            'class': 'Warden',
            'type': 'Rhombus',
            'description': '+1 rank to all Companion skills.',
            'value': '1'
          }),
        ]
      : [];
  return version;
}

Artifact byId(Version v, int id) => v.artifacts.firstWhere((a) => a.id == id);

void main() {
  test('fromJSON parses id, class, shape and fills in AMOUNT', () {
    var v = testVersion();
    var magnet = byId(v, 10002);
    expect(magnet.name, 'Magnetic Device');
    expect(magnet.shape, ArtifactShape.TRIANGLE);
    expect(magnet.requiresClass, isNull);
    expect(magnet.desc, '+50% Pickup Radius.');
    expect(byId(v, 10026).requiresClass.name, 'Warden');
  });

  test('slots 0-1 are Triangle, 2-3 Rhombus, 4-5 Star', () {
    expect([0, 1, 2, 3, 4, 5].map(Artifact.shapeOfSlot).toList(), [
      ArtifactShape.TRIANGLE,
      ArtifactShape.TRIANGLE,
      ArtifactShape.RHOMBUS,
      ArtifactShape.RHOMBUS,
      ArtifactShape.STAR,
      ArtifactShape.STAR,
    ]);
  });

  test('canHaveArtifact checks shape, class and other slots only', () {
    var v = testVersion();
    var mech = Character(v.classes[1]);
    var magnet = byId(v, 10002);
    expect(mech.canHaveArtifact(0, magnet), isTrue);
    expect(mech.canHaveArtifact(2, magnet), isFalse); // wrong shape
    expect(mech.canHaveArtifact(2, byId(v, 10026)), isFalse); // Warden only
    expect(Character(v.classes[0]).canHaveArtifact(2, byId(v, 10026)), isTrue);
    mech.artifacts[0] = magnet;
    expect(mech.canHaveArtifact(1, magnet), isFalse); // already in slot 0
    expect(mech.canHaveArtifact(0, magnet), isTrue); // re-picking slot 0
  });

  test('build link keeps artifacts', () {
    var v = testVersion();
    var mech = Character(v.classes[1]);
    mech.artifacts[0] = byId(v, 10002);
    mech.artifacts[1] = byId(v, 10005);
    var json = mech.asJSON;
    expect(json['artifacts'], [10002, 10005, null, null, null, null]);
    var loaded = Character.fromJSON([v], json);
    expect(loaded.artifacts.map((a) => a?.id).toList(),
        [10002, 10005, null, null, null, null]);
  });

  test('old build links without artifacts load with empty slots', () {
    var v = testVersion();
    var json = Character(v.classes[1]).asJSON..remove('artifacts');
    expect(Character.fromJSON([v], json).artifacts, everyElement(isNull));
  });

  test('wrong-shape or unknown artifact ids load as empty', () {
    var v = testVersion();
    var json = Character(v.classes[1]).asJSON;
    json['artifacts'] = [10026, 99999, 10002, null, null, null];
    expect(Character.fromJSON([v], json).artifacts, everyElement(isNull));
  });

  test('versions without artifacts ignore them in build links', () {
    var v = testVersion(withArtifacts: false);
    var json = Character(v.classes[1]).asJSON;
    json['artifacts'] = [10002, null, null, null, null, null];
    expect(Character.fromJSON([v], json).artifacts, everyElement(isNull));
  });
}
