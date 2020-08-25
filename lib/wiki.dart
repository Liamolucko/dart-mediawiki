import 'dart:convert';

import 'package:http/http.dart' as http;

import 'src/errors.dart';
import 'src/file.dart';
import 'src/page.dart';
import 'src/revision.dart';
import 'src/wrappers.dart';

export 'src/errors.dart';

class Wiki {
  String get url => _uri.toString();
  set url(String value) {
    _uri = Uri.parse(value);
  }

  String token;

  bool polyfilled;

  final http.Client _client = http.Client();

  Uri _uri;

  Wiki(Uri uri, [this.token]) : _uri = uri {
    polyfilled = _uri.pathSegments[_uri.pathSegments.length - 2] == 'api.php';
  }

  static Future<bool> _checkUrl(Uri url, [String token]) async {
    // Assume url is already valid path-wise
    if (url.pathSegments.last == 'api.php') {
      return (await http.get(url)).statusCode != 404;
    } else {
      return (await http.get(url.resolve('search/page?q=test'))).statusCode !=
          404;
    }
  }

  /// The primary constructor for [Wiki].
  /// You _can_ use the default constructor, but you need to enter the exact valid [Uri]
  /// and there's no error checking.
  ///
  /// You can enter the path to the api directly or just to the wiki's mediawiki installation,
  /// e.g. https://en.wikipedia.org/w/ or https://en.wikipedia.org/w/rest.php.
  ///
  /// If you want, you can specifically choose api.php to use the Actions API even if the REST API is available.
  ///
  /// Query parameters will be ignored.
  static Future<Wiki> fromUrl(String url, [String token]) async {
    // Ensure URL acts like directory
    if (!url.endsWith('/')) url += '/';

    var uri = Uri.parse(url);

    // Append `v1` to `rest.php`
    if (uri.pathSegments[uri.pathSegments.length - 2] == 'rest.php' &&
        await _checkUrl(uri.resolve('v1/'))) {
      uri = uri.resolve('v1/');
    }

    if (await _checkUrl(uri)) {
      // Uri is already valid
    } else if (await _checkUrl(uri.resolve('rest.php/v1/'))) {
      uri = uri.resolve('rest.php/v1/');
    } else if (await _checkUrl(uri.resolve('api.php/'))) {
      uri = uri.resolve('api.php/');
    } else {
      throw ArgumentError.value(url, 'url');
    }

    return Wiki(uri, token);
  }

  T _handleError<T>(T value) {
    try {
      final map = value is Map
          ? value
          : value is String
              ? json.decode(value)
              : throw ArgumentError('value must be a Map or a String');

      if (map is Map &&
          (map.containsKey('httpCode') ||
              map.containsKey('errors') ||
              map.containsKey('error'))) {
        throw ApiException.fromJson(map);
      } else {
        return value;
      }
    } on FormatException {
      // If it isn't valid JSON, it musn't be an error
      return value;
    }
  }

  /// Low-level API command.
  Future<String> request({
    String method = 'GET',
    String path = '',
    Map<String, String> params,
    Map<String, String> headers = const {},
    String body = '',
  }) {
    final uri = Uri(
      scheme: _uri.scheme,
      host: _uri.host,
      port: _uri.port,
      path: _uri.resolve(path).path,
      queryParameters: polyfilled
          ? {
              ...params,
              'format': 'json',
              'formatversion': '2',
              'errorformat': 'plaintext'
            }
          : params,
    );
    return _client
        .send(http.Request(method, uri)
          ..headers.addAll(headers) // package:http, why are you like this?
          ..body = body)
        .then((value) => value.stream.bytesToString())
        .then(_handleError);
  }

  Future<dynamic> requestJson({
    String path = '',
    Map<String, String> params,
    Map<String, String> headers = const {},
    String method = 'GET',
    String body = '',
  }) =>
      request(
        path: path,
        params: params,
        headers: headers,
        method: method,
        body: body,
      ).then((value) => json.decode(value));

  Future<dynamic> getJson(dynamic url, {Map<String, String> headers}) async =>
      json.decode(await _client
          .get(url, headers: headers)
          .then((response) => response.body)
          .then(_handleError));

  /// Searches wiki page titles and contents for the provided search terms [query], and returns up to [limit] (default 50) matching pages.
  Future<Iterable<SearchResult>> search(String query, [int limit]) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('limit must be between 1 and 100');
    }

    return (await requestJson(
      path: 'search/page',
      params: {'q': query, 'limit': limit.toString()},
    ))['pages']
        .map((result) {
      assert(result.containsKey('pages') && result['pages'] is List<Map>,
          'Invalid API response recieved');

      return result['pages'].map((result) => SearchResult.fromJson(result));
    });
  }

  /// Searches wiki page titles, and returns up to [limit] (default 50) matches between the beginning of a title and the provided search terms [query]. You can use this endpoint for a typeahead search that automatically suggests relevant pages by title.
  Future<Iterable<SearchResult>> complete(String query, [int limit]) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('limit must be between 1 and 100');
    }

    return (await requestJson(
            path: 'search/title',
            params: {'q': query, 'limit': limit.toString()}))['pages']
        .map((result) {
      assert(result.containsKey('pages') && result['pages'] is List<Map>,
          'Invalid API response recieved');

      return result['pages'].map((result) => SearchResult.fromJson(result));
    });
  }

  /// Returns a [PageFuture] for the page named [title].
  ///
  /// You can access any of the page's properties through
  /// async property accessors, or by awaiting it to get the resolved [Page].
  ///
  /// ```
  /// print(await wiki.page('Jupiter').title);
  ///
  /// // OR
  /// let data = await wiki.page('Jupiter');
  /// print(data.title);
  ///
  /// // OR
  /// let data = await page.fetch();
  /// print(data.title);
  /// ```
  PageFuture page(String title) => PageFuture(this, title);

  /// Returns information about the file [title],
  /// including links to download the file in thumbnail, preview, and original formats.
  FileFuture file(String title) => FileFuture(this, title);

  /// Returns details for an individual revision.
  ///
  /// It can also be chained for the effect of `compare()`:
  /// ```typescript
  /// await wiki.revision(42).compare(43);
  /// // Is equivalent to
  /// await wiki.compare(42, 43);
  /// ```
  RevisionFuture revision(int id) => RevisionFuture(this, id);

  Future<Diff> compare(int from, int to) async =>
      Diff(await requestJson(path: 'revision/$from/compare/$to'));
}
