import 'package:chronomancer/artifact.dart';
import 'package:chronomancer/save_file.dart';
import 'package:chronomancer/version.dart';
import 'package:test/test.dart';

const E1ART =
    '930100000600000001000000050000003130305F310000000000000000808AC340'
    '01000000050000003130315F330000000000000000808EC340'
    '01000000050000003130315F310000000000000000808AC340'
    '01000000050000003130315F3200000000000000000090C340'
    '01000000050000003130305F3000000000000000000089C340'
    '01000000050000003130315F3000000000000000000089C340';

Version testVersion() {
  var version = Version('1.60.0');
  version.classes = [];
  version.artifacts = [
    Artifact(10002, 'Magnetic Device', '', ArtifactShape.TRIANGLE, null),
    Artifact(10005, 'Battle Lust', '', ArtifactShape.TRIANGLE, null),
    Artifact(10013, 'Focused Knowledge', '', ArtifactShape.RHOMBUS, null),
    Artifact(10016, "Attrition's Yield", '', ArtifactShape.RHOMBUS, null),
  ];
  return version;
}

List<int> ids(List<Artifact> artifacts) => artifacts.map((a) => a?.id).toList();

void main() {
  test('reads the current beast\'s slots from the real save value', () {
    // c[30] decodes as a double
    expect(ids(SaveFile.parseArtifacts(testVersion(), 101.0, E1ART)),
        [10002, 10005, 10016, 10013, null, null]);
  });

  test('leftover entries of an outgrown beast are not used', () {
    expect(ids(SaveFile.parseArtifacts(testVersion(), 102.0, E1ART)),
        everyElement(isNull));
  });

  test('no beast, no DLC or no artifact map gives empty slots', () {
    var v = testVersion();
    for (var result in [
      SaveFile.parseArtifacts(v, -4.0, E1ART),
      SaveFile.parseArtifacts(v, null, E1ART),
      SaveFile.parseArtifacts(v, 101.0, null),
      SaveFile.parseArtifacts(v, 101.0, ''),
    ]) {
      expect(result, hasLength(6));
      expect(result, everyElement(isNull));
    }
  });

  test('unknown artifact ids leave the slot empty', () {
    var v = testVersion()..artifacts.removeWhere((a) => a.id == 10016);
    expect(ids(SaveFile.parseArtifacts(v, 101.0, E1ART)),
        [10002, 10005, null, 10013, null, null]);
  });
}
