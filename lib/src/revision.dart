import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

import '../wiki.dart';
import 'future_proxy.dart';
import 'page.dart';
import 'wrappers.dart';

part 'revision.g.dart';

abstract class RevisionBase {
  Wiki _wiki;
  int id;

  Future<Diff> compare(int to) => _wiki.compare(id, to);
}

class RevisionFuture
    with FutureProxy<RevisionWithPage>
    implements Future<RevisionWithPage> {
  /// Revision identifier
  Future<int> id;

  /// Object containing information about the user that made the edit
  Future<User> user;

  /// Time of the edit in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format
  Future<String> timestamp;

  /// Comment or edit summary written by the editor. For revisions without a comment, the API returns `null` or `""`.
  Future<String> comment;

  /// Size of the revision in bytes
  Future<int> size;

  /// Number of bytes changed, positive or negative, between a revision and the preceding revision (example: `-20`). If the preceding revision is unavailable, the API returns `null`.
  Future<int> delta;

  /// Set to true for edits marked as [minor](https://meta.wikimedia.org/wiki/Help:Minor_edit)
  Future<bool> minor;

  /// Object containing information about the page
  Future<PageMetadata> page;

  RevisionFuture(Wiki wiki, int id, {bool includePage = true}) {
    future = wiki
        .requestJson(path: 'revision/$id')
        .then((value) => RevisionWithPage.fromJson(value));

    this.id = future.then((value) => value.id);
    user = future.then((value) => value.user);
    timestamp = future.then((value) => value.timestamp);
    comment = future.then((value) => value.comment);
    size = future.then((value) => value.size);
    delta = future.then((value) => value.delta);
    minor = future.then((value) => value.minor);
    page = future.then((value) => value.page);
  }
}

@JsonSerializable()
class Revision {
  /// Revision identifier
  @requiredKey
  int id;

  /// Object containing information about the user that made the edit
  @requiredKey
  User user;

  /// Time of the edit in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format
  @requiredKey
  String timestamp;

  /// Comment or edit summary written by the editor. For revisions without a comment, the API returns `null` or `""`.
  String comment;

  /// Size of the revision in bytes
  @requiredKey
  int size;

  /// Number of bytes changed, positive or negative, between a revision and the preceding revision (example: `-20`). If the preceding revision is unavailable, the API returns `null`.
  int delta;

  /// Set to true for edits marked as [minor](https://meta.wikimedia.org/wiki/Help:Minor_edit)
  @requiredKey
  bool minor;

  Revision({
    this.id,
    this.user,
    this.timestamp,
    this.comment,
    this.size,
    this.delta,
    this.minor,
  });

  factory Revision.fromJson(Map<String, dynamic> json) =>
      _$RevisionFromJson(json);
}

@JsonSerializable()
class RevisionWithPage extends Revision {
  /// Object containing information about the page
  @requiredKey
  PageMetadata page;

  RevisionWithPage({
    int id,
    User user,
    String timestamp,
    String comment,
    int size,
    int delta,
    bool minor,
    this.page,
  }) : super(
          id: id,
          user: user,
          comment: comment,
          size: size,
          delta: delta,
          minor: minor,
        );

  factory RevisionWithPage.fromJson(Map<String, dynamic> json) =>
      _$RevisionWithPageFromJson(json);
}
