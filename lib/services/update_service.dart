import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String _currentVersion = '1.0.2';
  static const String _versionUrl = 'https://raw.githubusercontent.com/BlackHatDevX/androbuster/refs/heads/main/VERSION';
  static const String _releasesUrl = 'https://github.com/BlackHatDevX/androbuster/releases';
  static const String _telegramUrl = 'https://t.me/androbuster';
  static const String _githubUrl = 'https://github.com/BlackHatDevX/androbuster';

  static Future<UpdateCheckResult> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));

      if (response.statusCode == 200) {
        final String versionContent = response.body.trim();
        final String? latestVersion = _extractVersion(versionContent);

        if (latestVersion != null) {
          final int comparison = _compareVersions(_currentVersion, latestVersion);

          if (comparison < 0) {
            return UpdateCheckResult.updateAvailable(latestVersion);
          } else if (comparison == 0) {
            return UpdateCheckResult.upToDate();
          } else {
            return UpdateCheckResult.currentVersionNewer();
          }
        } else {
          return UpdateCheckResult.error('Failed to parse version information');
        }
      } else {
        return UpdateCheckResult.error('Failed to check for updates. Status: ${response.statusCode}');
      }
    } catch (e) {
      return UpdateCheckResult.error('Error checking for updates: $e');
    }
  }

  static String? _extractVersion(String content) {
    final RegExp versionRegex = RegExp(r'VERSION=(\d+\.\d+\.\d+)');
    final Match? match = versionRegex.firstMatch(content);
    return match?.group(1);
  }

  static int _compareVersions(String current, String latest) {
    final List<int> currentParts = current.split('.').map(int.parse).toList();
    final List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final int currentPart = i < currentParts.length ? currentParts[i] : 0;
      final int latestPart = i < latestParts.length ? latestParts[i] : 0;

      if (currentPart < latestPart) return -1; 
      if (currentPart > latestPart) return 1;  
    }
    return 0; 
  }

  static Future<bool> openReleasesPage() async {
    try {
      final Uri url = Uri.parse(_releasesUrl);
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openTelegramGroup() async {
    try {
      final Uri url = Uri.parse(_telegramUrl);
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openGitHubRepository() async {
    try {
      final Uri url = Uri.parse(_githubUrl);
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String get currentVersion => _currentVersion;

  static String get releasesUrl => _releasesUrl;

  static String get telegramUrl => _telegramUrl;

  static String get githubUrl => _githubUrl;
}

class UpdateCheckResult {
  final UpdateStatus status;
  final String? latestVersion;
  final String? errorMessage;

  const UpdateCheckResult._({
    required this.status,
    this.latestVersion,
    this.errorMessage,
  });

  factory UpdateCheckResult.updateAvailable(String version) {
    return UpdateCheckResult._(
      status: UpdateStatus.updateAvailable,
      latestVersion: version,
    );
  }

  factory UpdateCheckResult.upToDate() {
    return UpdateCheckResult._(status: UpdateStatus.upToDate);
  }

  factory UpdateCheckResult.currentVersionNewer() {
    return UpdateCheckResult._(status: UpdateStatus.currentVersionNewer);
  }

  factory UpdateCheckResult.error(String message) {
    return UpdateCheckResult._(
      status: UpdateStatus.error,
      errorMessage: message,
    );
  }
}

enum UpdateStatus {
  updateAvailable,
  upToDate,
  currentVersionNewer,
  error,
}