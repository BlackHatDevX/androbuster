import 'package:flutter/material.dart';
import '../services/update_service.dart';

class AppDialogs {

  static void showThreadWarning(
    BuildContext context,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'High Thread Count Warning',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: const Text(
            'Setting thread count above 20 may cause:\n\n'
            '• Server rate limiting/blocking\n'
            '• Increased network usage\n'
            '• Potential IP blocking\n'
            '• Unstable scanning\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onContinue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue Anyway'),
            ),
          ],
        );
      },
    );
  }

  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('About AndroBuster'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AndroBuster ${UpdateService.currentVersion}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('A powerful directory and subdomain enumeration tool built with Flutter.'),
              const SizedBox(height: 8),
              const Text('Features:'),
              const Text('• Directory enumeration'),
              const Text('• Subdomain discovery'),
              const Text('• Multi-threaded scanning'),
              const Text('• Customizable filters'),
              const SizedBox(height: 8),
              const Text('Built for security researchers and penetration testers.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                final bool opened = await UpdateService.openGitHubRepository();
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open GitHub repository')),
                  );
                }
              },
              icon: const Icon(Icons.code),
              label: const Text('GitHub'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  static void showTelegramDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.telegram, color: Colors.blue),
              SizedBox(width: 8),
              Text('Join Our Telegram'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Join our Telegram channel for updates, support, and community discussions.'),
              SizedBox(height: 8),
              Text('Link: https://t.me/androbuster', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final bool opened = await UpdateService.openTelegramGroup();
                if (!opened) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open Telegram link')),
                    );
                  }
                }
              },
              child: const Text('Open Telegram'),
            ),
          ],
        );
      },
    );
  }

  static void showUpdateAvailableDialog(
    BuildContext context,
    String latestVersion,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Colors.orange),
              SizedBox(width: 8),
              Text('Update Available!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Version: ${UpdateService.currentVersion}'),
              Text('Latest Version: v$latestVersion', 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 8),
              const Text('A new version is available. Click the update button to download it.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final bool opened = await UpdateService.openReleasesPage();
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to open releases page')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Download Update'),
            ),
          ],
        );
      },
    );
  }

  static void showUpToDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Up to Date'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Version: ${UpdateService.currentVersion}'),
              const SizedBox(height: 8),
              const Text('You are using the latest version!', 
                style: TextStyle(color: Colors.green)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Update Check Failed'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static void showUpdateLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Flexible(
                child: Text('Checking for Updates...'),
              ),
            ],
          ),
          content: Text('Please wait while we check for the latest version.'),
        );
      },
    );
  }
}