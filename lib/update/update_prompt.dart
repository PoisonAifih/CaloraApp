import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/calora_theme.dart';
import 'github_update.dart';
import 'version.dart';

class UpdateScope extends InheritedWidget {
  const UpdateScope({required this.client, required super.child, super.key});

  final GithubUpdateClient client;

  static GithubUpdateClient? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UpdateScope>()?.client;
  }

  @override
  bool updateShouldNotify(UpdateScope oldWidget) => oldWidget.client != client;
}

class UpdatePrompt extends StatefulWidget {
  const UpdatePrompt({required this.client, required this.child, super.key});

  final GithubUpdateClient client;
  final Widget child;

  @override
  State<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends State<UpdatePrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) promptGithubUpdate(context, widget.client);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> promptGithubUpdate(BuildContext context, GithubUpdateClient client, {bool force = false}) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final release = await client.newerThan(info.version, info.buildNumber);
    if (release == null || !context.mounted) return;
    if (Theme.of(context).platform != TargetPlatform.android) {
      if (force) {
        await launchUrl(Uri.parse('https://github.com/${client.repo}/releases/tag/${release.tag}'), mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (!force && client.ignoredTag == release.tag) return;
    final install = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update available'),
        content: Text('Version ${release.tag} is on GitHub. Install it now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Install'),
          ),
        ],
      ),
    );
    if (install != true) {
      client.ignoredTag = release.tag;
      return;
    }
    if (!context.mounted) return;
    await _downloadAndInstall(context, client, release);
  } on GithubUpdateException catch (error) {
    if (force && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

Future<void> _downloadAndInstall(BuildContext context, GithubUpdateClient client, GithubRelease release) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(color: CaloraColors.accent),
          SizedBox(width: 16),
          Expanded(child: Text('Downloading update')),
        ],
      ),
    ),
  );
  try {
    final path = await client.download(release);
    final opened = await OpenFilex.open(path, type: 'application/vnd.android.package-archive');
    if (opened.type != ResultType.done) {
      throw GithubUpdateException(opened.message.isEmpty ? 'Android did not open the installer' : opened.message);
    }
  } on GithubUpdateException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}
