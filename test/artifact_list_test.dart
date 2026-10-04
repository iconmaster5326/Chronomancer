import 'package:chronomancer/artifact.dart';
import 'package:chronomancer/version.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('only versions from 1.60.0 onwards fetch artifacts.json', () async {
    var requested = <String>[];
    var http = MockClient((request) async {
      requested.add(request.url.path);
      return Response('[]', 200);
    });
    for (var name in ['1.10.2', '1.40.1', '1.60.0']) {
      var version = Version(name)..classes = [];
      await Artifact.getArtifactList(version, http);
    }
    expect(requested, ['assets/json/1.60.0/artifacts.json']);
  });
}
