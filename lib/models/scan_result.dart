class ScanResult {
  final String path;
  final int statusCode;
  final int size;
  final String url;

  const ScanResult({
    required this.path,
    required this.statusCode,
    required this.size,
    required this.url,
  });

  @override
  String toString() {
    return 'ScanResult(path: $path, statusCode: $statusCode, size: $size, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanResult &&
        other.path == path &&
        other.statusCode == statusCode &&
        other.size == size &&
        other.url == url;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        statusCode.hashCode ^
        size.hashCode ^
        url.hashCode;
  }
}