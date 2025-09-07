/// Utilities for working with URLs in the app.
class UrlUtils {
  /// Converts WordPress media URLs hosted on seify.ir to the app CDN domain.
  ///
  /// Example:
  /// https://seify.ir/wp-content/uploads/2025/02/pic.webp
  ///   -> https://app.seify.ir/media/2025/02/pic.webp
  ///
  /// If the URL is already pointing to app.seify.ir/media or doesn't match
  /// the expected input host/path, it will be returned unchanged.
  static String convertSeifyImageUrl(String? inputUrl) {
    if (inputUrl == null || inputUrl.isEmpty) return inputUrl ?? '';

    Uri? uri;
    try {
      uri = Uri.tryParse(inputUrl);
    } catch (_) {
      return inputUrl; // leave as-is on parse failure
    }
    if (uri == null) return inputUrl;

    // Already on target domain/path
    if ((uri.host == 'app.seify.ir') &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'media') {
      return uri.toString();
    }

    const sourceHosts = {'seify.ir', 'www.seify.ir'};
    const sourcePrefix = '/wp-content/uploads/';

    if (sourceHosts.contains(uri.host) && uri.path.startsWith(sourcePrefix)) {
      final remainder = uri.path.substring(sourcePrefix.length);
      final newUri = Uri(
        scheme: 'https',
        host: 'app.seify.ir',
        path: '/media/$remainder',
        query: uri.query.isNotEmpty ? uri.query : null,
        fragment: uri.fragment.isNotEmpty ? uri.fragment : null,
      );
      return newUri.toString();
    }

    // Not a match; return original
    return inputUrl;
  }
}
