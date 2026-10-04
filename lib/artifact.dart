import 'dart:convert';
import 'package:http/http.dart';

import 'class.dart';
import 'util.dart';
import 'version.dart';

enum ArtifactShape {
  TRIANGLE,
  RHOMBUS,
  STAR,
}

const Map<ArtifactShape, String> ARTIFACT_SHAPE_TO_STRING =
    <ArtifactShape, String>{
  ArtifactShape.TRIANGLE: 'Triangle',
  ArtifactShape.RHOMBUS: 'Rhombus',
  ArtifactShape.STAR: 'Star',
};

/// Only versions from 1.60.0 onwards have artifacts.
bool _hasArtifacts(Version version) {
  var parts = version.name.split('.').map(int.parse).toList();
  return parts[0] > 1 || (parts[0] == 1 && parts[1] >= 60);
}

class Artifact {
  int id;
  String name, desc;
  ArtifactShape shape;
  CharClass requiresClass;

  Artifact(this.id, this.name, this.desc, this.shape, this.requiresClass);

  Artifact.fromJSON(Version version, Map<String, dynamic> j)
      : id = int.parse(j['uuid']),
        name = j['name'],
        desc = (j['description'] as String)
            .replaceAll('AMOUNT', j['value'].toString()),
        shape = ARTIFACT_SHAPE_TO_STRING.inverted[j['type']],
        requiresClass = version.classWithName(j['class']);

  // slots 0-1 take Triangles, 2-3 Rhombuses and 4-5 Stars
  static ArtifactShape shapeOfSlot(int slot) => ArtifactShape.values[slot ~/ 2];

  bool usableBy(CharClass charClass) =>
      requiresClass == null || requiresClass == charClass;

  static Future<List<Artifact>> getArtifactList(
      Version version, Client http) async {
    if (!_hasArtifacts(version)) return [];
    final response =
        await http.get('assets/json/${version.name}/artifacts.json');
    if (response.statusCode != 200) return [];
    // entries without a shape (Red Wail) can't be put in any slot
    return (json.decode(response.body) as List)
        .where((j) => ARTIFACT_SHAPE_TO_STRING.containsValue(j['type']))
        .map((j) => Artifact.fromJSON(version, j))
        .toList();
  }
}
