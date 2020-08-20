import 'dart:async';

import '../wiki.dart';
import 'errors.dart';
import 'revision.dart';

class History extends Stream<Revision> {
  final Wiki _wiki;
  final String _title;

  final String _filter;
  final int _limit;

  History(Wiki wiki, String title, {String filter, int limit})
      : _wiki = wiki,
        _title = title,
        _filter = filter,
        _limit = limit;

  /// Configures all options at once
  History config({String filter, int limit}) {
    return History(_wiki, _title, filter: filter, limit: limit);
  }

  /// Allows page history to be called like a function for immediate
  /// configuration.
  ///
  /// ```
  /// wiki.page('Jupiter').history(filter: 'bot');
  /// ```
  History call({String filter, int limit}) =>
      config(filter: filter, limit: limit);

  /// Gets a [HistorySegment] of the last 20 revisions.
  ///
  /// [HistorySegment]s can be stepped through with `newer` and `older`.
  Future<HistorySegment> get latest async => HistorySegment.fromJson(
      _wiki,
      await _wiki.requestJson(
          path: 'page/$_title/history',
          params: {'filter': _filter}
            ..removeWhere((key, value) => value == null)));

  /// Returns up to 20 revisions older than revision [id] as a HistorySegment.
  ///
  /// [HistorySegment]s can be stepped through with `newer` and `older`.
  Future<HistorySegment> olderThan(int id) async => HistorySegment.fromJson(
      _wiki,
      await _wiki.requestJson(
          path: 'page/$_title/history',
          params: {'filter': _filter, 'older_than': id.toString()}
            ..removeWhere((key, value) => value == null)));

  /// Returns up to 20 revisions newer than revision [id] as a HistorySegment.
  ///
  /// [HistorySegment]s can be stepped through with `newer` and `older`.
  Future<HistorySegment> newerThan(int id) async => HistorySegment.fromJson(
      _wiki,
      await _wiki.requestJson(
          path: 'page/$_title/history',
          params: {'filter': _filter, 'newer_than': id.toString()}
            ..removeWhere((key, value) => value == null)));

  Stream<Revision> _createStream([int from, int to]) async* {
    if (from != null) yield await _wiki.revision(from);

    var count = 0;
    for (var segment = await (from == null ? latest : olderThan(from));
        segment.hasOlder;
        segment = await segment.older) {
      for (var revision in segment.revisions) {
        if (revision.id == to) return;
        yield revision;
        count++;
        if (count >= _limit) return;
      }
    }
  }

  /// Returns a slice of this page's history from revision [from] (inclusive)
  /// to revision [to] (exclusive)
  Future<List<Revision>> slice(int from, int to) =>
      _createStream(from, to).toList();

  @override
  StreamSubscription<Revision> listen(void Function(Revision event) onData,
          {Function onError, void Function() onDone, bool cancelOnError}) =>
      _createStream().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}

class HistorySegment {
  final Wiki _wiki;

  final List<Revision> revisions;
  int get length => revisions.length;

  String _newerUrl;
  Future<HistorySegment> get newer async {
    if (_newerUrl == null) return null;
    return HistorySegment.fromJson(_wiki, await _wiki.getJson(_newerUrl));
  }

  bool get hasNewer => _newerUrl != null;

  String _olderUrl;
  Future<HistorySegment> get older async {
    if (_olderUrl == null) return null;
    return HistorySegment.fromJson(_wiki, await _wiki.getJson(_olderUrl));
  }

  bool get hasOlder => _olderUrl != null;

  String _latestUrl;
  Future<HistorySegment> get latest async =>
      HistorySegment.fromJson(_wiki, await _wiki.getJson(_latestUrl));

  HistorySegment(Wiki wiki, this.revisions,
      {String newer, String older, String latest})
      : _wiki = wiki,
        _newerUrl = newer,
        _olderUrl = older,
        _latestUrl = latest;

  factory HistorySegment.fromJson(Wiki wiki, Map data) {
    if (data['revisions'] is List && data['latest'] is String) {
      return HistorySegment(wiki,
          (data['revisions'] as List).map((e) => Revision.fromJson(e)).toList(),
          latest: data['latest'], older: data['older'], newer: data['newer']);
    } else {
      throw InvalidResponseException();
    }
  }
}
