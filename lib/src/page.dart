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
  Future<String> get html async {
    if (_wiki.polyfilled) {
      try {
        return (await _wiki.requestJson(params: {
          'action': 'parse',
          'page': title,
          'prop': 'text'
        }))['parse']['text'];
      } on Error {
        throw InvalidResponseException();
      }
    } else {
      return _wiki.request(path: 'page/$title/html');
    }
  }

  /// Pages with the same topic in different languages.
  Future<Iterable<Language>> get languages async {
    if (_wiki.polyfilled) {
      try {
        return ((await _wiki.requestJson(
                    params: {'action': 'parse', 'prop': 'langlinks'}))['parse']
                ['langlinks'] as List)
            .map((link) => Language(
                code: link['lang'],
                name: link['autonym'],
                key: (link['title'] as String).replaceAll(' ', '_'),
                title: link['title']));
      } on Error {
        throw InvalidResponseException();
      }
    } else {
      return _wiki.requestJson(path: 'page/$title/links/language').then(
          (value) => (value as Iterable).map((e) => Language.fromJson(e)));
    }
  }

  /// Information about files used on this page.
  Future<Iterable<File>> get files async =>
      await _wiki.requestJson(path: 'page/$title/links/media').then((value) =>
          (value['files'] as List).map((file) => File.fromJson(file)));

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
            if (_wiki.token != null) 'Authorization': 'Bearer ${_wiki.token}'
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
            if (_wiki.token != null) 'Authorization': 'Bearer ${_wiki.token}'
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

  Future<Page> fetch() async {
    if (_wiki.polyfilled) {
      return Page.fromActions(
          _wiki,
          await _wiki.requestJson(params: {
            'action': 'query',
            'titles': title,
            'prop': 'revisions|info',
            'rvprop': 'timestamp|ids|content',
            'rvslots': 'main',
            'rvlimit': '1',
            'meta': 'siteinfo',
            'siprop': 'rightsinfo'
          }));
    } else {
      return Page.fromJson(_wiki, await _wiki.requestJson(path: 'page/$title'));
    }
  }

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
  factory Page.fromJson(Wiki wiki, Map json) {
    try {
      return Page(wiki,
          id: json['id'],
          key: json['key'],
          title: json['title'],
          latest: PageRevision.fromJson(json['latest']),
          contentModel: json['content_model'],
          license: License.fromJson(json['license']),
          source: json['source']);
    } on TypeError {
      throw InvalidResponseException();
    }
  }

  factory Page.fromActions(Wiki wiki, Map json) {
    try {
      return Page(wiki,
          id: json['query']['pages'][0]['pageid'],
          key: (json['query']['pages'][0]['title'] as String)
              .replaceAll(' ', '_'),
          title: json['query']['pages'][0]['title'],
          latest: PageRevision(
              id: json['query']['pages'][0]['lastrevid'],
              timestamp: json['query']['pages'][0]['revisions'][0]
                  ['timestamp']),
          contentModel: json['query']['pages'][0]['contentmodel'],
          license: License(
              url: json['query']['rightsinfo']['url'],
              title: json['query']['rightsinfo']['text']),
          source: json['query']['pages'][0]['revisions'][0]['slots']['main']
              ['content']);
    } on TypeError {
      throw InvalidResponseException();
    } on NoSuchMethodError {
      try {
        if (json['query']['pages'][0]['missing']) {
          throw ApiException(
              'The specified title (${json['query']['pages'][0]['title']}) does not exist');
        } else {
          throw InvalidResponseException();
        }
      } on NoSuchMethodError {
        throw InvalidResponseException();
      }
    }
  }
}
