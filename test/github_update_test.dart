import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:calora_app/update/github_update.dart';
import 'package:calora_app/update/version.dart';

void main() {
  test('parses a release tag and ignores an older build', () {
    final installed = parseAppVersion('1.0.0+1');
    final same = parseAppVersion('v1.0.0+1');
    final newer = parseAppVersion('v1.0.1+2');
    expect(installed, isNotNull);
    expect(isNewerThanInstalled(installed!, same!), isFalse);
    expect(isNewerThanInstalled(installed, newer!), isTrue);
  });

  test('reads the apk url from the latest GitHub release', () async {
    final client = GithubUpdateClient(
      repo: 'PoisonAifih/CaloraApp',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/repos/PoisonAifih/CaloraApp/releases/latest');
        return http.Response(
          '{"tag_name":"v1.0.1+2","assets":[{"name":"app-release.apk","browser_download_url":"https://example.test/app-release.apk"}]}',
          200,
        );
      }),
    );

    final release = await client.newerThan('1.0.0', '1');
    expect(release?.tag, 'v1.0.1+2');
    expect(release?.apkUrl, 'https://example.test/app-release.apk');
  });
}
