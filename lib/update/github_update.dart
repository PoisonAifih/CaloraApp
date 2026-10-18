import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'version.dart';

class GithubUpdateClient {
  GithubUpdateClient({http.Client? httpClient, this.repo = 'PoisonAifih/CaloraApp'}) : httpClient = httpClient ?? http.Client();

  final http.Client httpClient;
  final String repo;
  String? ignoredTag;

  Future<GithubRelease?> latest() async {
    final response = await httpClient.get(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
      headers: const {'Accept': 'application/vnd.github+json', 'User-Agent': 'CaloraApp'},
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode >= 400) {
      throw GithubUpdateException('GitHub returned ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    return releaseFromJson(decoded);
  }

  Future<GithubRelease?> newerThan(String version, String buildNumber) async {
    final installed = parseAppVersion('$version+$buildNumber');
    final published = await latest();
    if (installed == null || published == null) return null;
    if (!isNewerThanInstalled(installed, published.version)) return null;
    return published;
  }

  Future<String> download(GithubRelease release) async {
    final response = await httpClient.get(
      Uri.parse(release.apkUrl),
      headers: const {'Accept': 'application/octet-stream', 'User-Agent': 'CaloraApp'},
    );
    if (response.statusCode >= 400) {
      throw GithubUpdateException('The update could not be downloaded');
    }
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/calora-update.apk');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }
}

class GithubUpdateException implements Exception {
  GithubUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}
