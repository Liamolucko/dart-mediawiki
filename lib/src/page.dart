import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../wiki.dart';
import 'errors.dart';
import 'file.dart';
import 'future_proxy.dart';
import 'history.dart';
import 'wrappers.dart';

part 'page.g.dart';

abstract class PageBase {
  Wiki _wiki;

  /// Page title in reading-friendly format
  String title;

  /// Latest page content in HTML, following the [HTML 2.1.0 specification](https://www.mediawiki.org/wiki/Specs/HTML/2.1.0)
  Future<String> get html => _wiki.request(path: 'page/$title/html');

  /// Pages with the same topic in different languages.
  Future<List<Language>> get languages =>
      _wiki.requestJson(path: 'page/$title/links/language').then(
          (value) => (value as List).map((e) => Language.fromJson(e)).toList());

  /// Information about files used on this page.
  Future<List<File>> get files async => await _wiki
      .requestJson(path: 'page/$title/links/media')
      .then((value) => value['files'] as List)
      .then((value) => value.map((file) => File.fromJson(file)).toList());

  /// The history of this page
  History get history => History(_wiki, title);

  /// Creates a wiki page.
  /// The response includes a `location` header containing
  /// the API endpoint to fetch the new page.
  ///
  /// This endpoint is designed to be used with the
  /// OAuth extension authorization process.
  /// Callers using cookie-based authentication instead
  /// must include a CSRF [token].
  /// To get a CSRF token, see the
  /// [Action API](https://www.mediawiki.org/wiki/API:Tokens).
  Future<PageBase> create(
          {String source, String comment, String contentModel, String token}) =>
      _wiki.requestJson(
          path: 'page',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...(_wiki.token != null
                ? {'Authorization': 'Bearer ${_wiki.token}'}
                : null)
          },
          body: json.encode({
            'title': title,
            'source': source,
            'comment': comment,
            'content_model': contentModel,
            'token': token
          }));

  /// Updates or creates a wiki page.
  /// This endpoint is designed to be used with the
  /// OAuth extension authorization process.
  /// Callers using cookie-based authentication instead
  /// must include a CSRF [token].
  /// To get a CSRF token, see the Action API.
  ///
  /// To update a page, you need the page's latest revision ID
  /// and the page source. First call the get page source endpoint,
  /// and then use the [source] and [latestId] to update the page.
  /// If [latestId] doesn't match the page's latest revision,
  /// the API resolves conflicts automatically when possible.
  /// In the event of an edit conflict, the API returns a 409 error.
  ///
  /// To create a page, omit [latestId] from the request.
  Future<PageBase> update(
          {String source,
          String comment,
          int latestId,
          String contentModel,
          String token}) =>
      _wiki.requestJson(
          path: 'page/$title',
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            ...(_wiki.token != null
                ? {'Authorization': 'Bearer ${_wiki.token}'}
                : null)
          },
          body: json.encode({
            'title': title,
            'source': source,
            'comment': comment,
            'content_model': contentModel,
            'token': token
          }));
}

class PageFuture extends PageBase
    with FutureProxy<Page>
    implements Future<Page> {
  @override
  final Wiki _wiki;

  /// Page title in reading-friendly format
  @override
  final String title;

  /// Page identifier
  Future<int> get id async => (await fetch()).id;

  /// Page title in URL-friendly format
  Future<String> get key async => (await fetch()).key;

  /// Information about the latest revision
  Future<PageRevision> get latest async => (await fetch()).latest;

  /// Type of content on the page. See [the content handlers reference](https://www.mediawiki.org/wiki/Content_handlers) for content models supported by MediaWiki and extensions.
  Future<String> get contentModel async => (await fetch()).contentModel;

  /// Information about the wiki's license
  Future<License> get license async => (await fetch()).license;

  /// Latest page content in the format specified by the `content_model` property
  Future<String> get source async => (await fetch()).source;

  PageFuture(Wiki wiki, this.title) : _wiki = wiki;

  Future<Page> fetch() async =>
      Page.fromJson(_wiki, await _wiki.requestJson(path: 'page/$title'));

  @override
  @protected
  Future<Page> get future => fetch();
}

@JsonSerializable()
class PageMetadata {
  /// Page identifier
  @requiredKey
  final int id;

  /// Page title in reading-friendly format
  @requiredKey
  final String title;

  PageMetadata({this.id, this.title});

  factory PageMetadata.fromJson(Map<String, dynamic> json) =>
      _$PageMetadataFromJson(json);
}

class Page extends PageBase {
  @override
  final Wiki _wiki;

  /// Page identifier
  final int id;

  /// Page title in URL-friendly format
  final String key;

  /// Page title in reading-friendly format
  @override
  final String title;

  /// Information about the latest revision
  final PageRevision latest;

  /// Type of content on the page. See [the content handlers reference](https://www.mediawiki.org/wiki/Content_handlers) for content models supported by MediaWiki and extensions.
  final String contentModel;

  /// Information about the wiki's license
  final License license;

  /// Latest page content in the format specified by [contentModel]
  final String source;

  Page(Wiki wiki,
      {this.id,
      this.key,
      this.title,
      this.latest,
      this.contentModel,
      this.license,
      this.source})
      : _wiki = wiki,
        super();

  // I couldn't use `json_serializable` because of `wiki`
  factory Page.fromJson(Wiki wiki, Map data) {
    if (data['id'] is int &&
        data['key'] is String &&
        data['title'] is String &&
        data['latest'] is Map &&
        data['content_model'] is String &&
        data['license'] is Map &&
        data['source'] is String) {
      return Page(wiki,
          id: data['id'],
          key: data['key'],
          title: data['title'],
          latest: PageRevision.fromJson(data['latest']),
          contentModel: data['content_model'],
          license: License.fromJson(data['license']),
          source: data['source']);
    } else {
      throw InvalidResponseException();
    }
  }
}
