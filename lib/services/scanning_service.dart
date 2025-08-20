import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../models/scan_result.dart';

class ScanningService {
  static const String _userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36';

  static Future<ScanResult?> scanPath(
    String path,
    String baseUrl,
    List<int> negativeStatusCodes,
    List<int> negativePageSizes,
    int timeoutMs,
  ) async {
    final String fullUrl = '$baseUrl/$path';

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {'User-Agent': _userAgent},
      ).timeout(Duration(milliseconds: timeoutMs));

      final int responseSize = response.contentLength ?? 0;

      if (!negativeStatusCodes.contains(response.statusCode) && 
          !negativePageSizes.contains(responseSize)) {
        return ScanResult(
          path: path,
          statusCode: response.statusCode,
          size: responseSize,
          url: fullUrl,
        );
      }
    } catch (e) {

    }

    return null;
  }

  static Future<ScanResult?> scanSubdomain(
    String subdomain,
    String domain,
    List<int> negativeStatusCodes,
    List<int> negativePageSizes,
    int timeoutMs,
  ) async {
    final String fullDomain = '$subdomain.$domain';

    try {

      final httpsResponse = await http.get(
        Uri.parse('https://$fullDomain'),
        headers: {'User-Agent': _userAgent},
      ).timeout(Duration(milliseconds: timeoutMs));

      final int responseSize = httpsResponse.contentLength ?? 0;

      if (!negativeStatusCodes.contains(httpsResponse.statusCode) && 
          !negativePageSizes.contains(responseSize)) {
        return ScanResult(
          path: subdomain,
          statusCode: httpsResponse.statusCode,
          size: responseSize,
          url: 'https://$fullDomain',
        );
      }
    } catch (e) {

      try {
        final httpResponse = await http.get(
          Uri.parse('http://$fullDomain'),
          headers: {'User-Agent': _userAgent},
        ).timeout(Duration(milliseconds: timeoutMs));

        final int responseSize = httpResponse.contentLength ?? 0;

        if (!negativeStatusCodes.contains(httpResponse.statusCode) && 
            !negativePageSizes.contains(responseSize)) {
          return ScanResult(
            path: subdomain,
            statusCode: httpResponse.statusCode,
            size: responseSize,
            url: 'http://$fullDomain',
          );
        }
      } catch (e2) {

      }
    }

    return null;
  }

  static bool isValidSubdomain(String subdomain) {
    if (subdomain.isEmpty) return false;

    if (subdomain.length > 63) return false;

    if (!RegExp(r'^[a-zA-Z0-9]').hasMatch(subdomain) || 
        !RegExp(r'[a-zA-Z0-9]$').hasMatch(subdomain)) {
      return false;
    }

    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(subdomain)) {
      return false;
    }

    if (subdomain.contains('--')) return false;

    if (subdomain.startsWith('-') || subdomain.endsWith('-')) return false;

    if (RegExp(r'^[0-9]+$').hasMatch(subdomain)) return false;

    return true;
  }

  static Future<String> readFileInChunks(File file) async {
    try {

      final int fileSize = await file.length();
      if (fileSize < 5 * 1024 * 1024) { 
        return await file.readAsString();
      }

      final stream = file.openRead();
      final buffer = StringBuffer();

      await for (final chunk in stream.transform(utf8.decoder)) {
        buffer.write(chunk);

        if (buffer.length > 100 * 1024 * 1024) { 
          throw Exception('File content too large to process safely');
        }
      }

      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  static List<String> parseWordlist(String text) {
    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('#'))
        .map((e) => e.contains('#') ? e.substring(0, e.indexOf('#')).trim() : e)
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static List<String> parseSubdomainWordlist(String text) {
    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('#'))
        .map((e) => e.contains('#') ? e.substring(0, e.indexOf('#')).trim() : e)
        .where((e) => e.isNotEmpty)
        .where((e) => isValidSubdomain(e))
        .toList();
  }

  static List<int> parseIntegerList(String text, {List<int> defaultValue = const [0]}) {
    try {
      return text
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
    } catch (e) {
      return defaultValue;
    }
  }

  static String cleanUrl(String url) {
    String cleaned = url.trim();
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }

  static String cleanDomain(String domain) {
    String cleaned = domain.trim().toLowerCase();
    if (cleaned.startsWith('http://')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('https://')) {
      cleaned = cleaned.substring(8);
    }
    if (cleaned.startsWith('www.')) {
      cleaned = cleaned.substring(4);
    }
    return cleaned;
  }
}