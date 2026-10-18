class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, this.build);

  final int major;
  final int minor;
  final int patch;
  final int build;

  @override
  int compareTo(AppVersion other) {
    final parts = [major.compareTo(other.major), minor.compareTo(other.minor), patch.compareTo(other.patch), build.compareTo(other.build)];
    for (final part in parts) {
      if (part != 0) return part;
    }
    return 0;
  }
}

AppVersion? parseAppVersion(String raw) {
  final match = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$').firstMatch(raw.trim());
  if (match == null) return null;
  return AppVersion(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
    int.parse(match.group(4) ?? '0'),
  );
}

class GithubRelease {
  const GithubRelease({required this.tag, required this.apkUrl, required this.version});

  final String tag;
  final String apkUrl;
  final AppVersion version;
}

GithubRelease? releaseFromJson(Map<String, dynamic> json) {
  final tag = json['tag_name'];
  if (tag is! String) return null;
  final version = parseAppVersion(tag);
  if (version == null) return null;
  final assets = json['assets'];
  if (assets is! List) return null;
  for (final asset in assets) {
    if (asset is! Map) continue;
    final name = asset['name'];
    final url = asset['browser_download_url'];
    if (name is String && name.endsWith('.apk') && url is String && url.isNotEmpty) {
      return GithubRelease(tag: tag, apkUrl: url, version: version);
    }
  }
  return null;
}

bool isNewerThanInstalled(AppVersion installed, AppVersion published) => published.compareTo(installed) > 0;
