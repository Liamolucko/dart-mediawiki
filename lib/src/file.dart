import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

import '../wiki.dart';
import 'future_proxy.dart';
import 'wrappers.dart';

part 'file.g.dart';

@JsonSerializable()
class FileRevision {
  /// Time of the edit in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format
  @requiredKey
  String timestamp;

  /// Object containing information about the user who uploaded the file
  @requiredKey
  User user;

  FileRevision(this.timestamp, this.user);

  factory FileRevision.fromJson(Map<String, dynamic> json) =>
      _$FileRevisionFromJson(json);
}

@JsonSerializable()
class File {
  /// File title
  @requiredKey
  String title;

  /// URL for the page describing the file, including license information and other metadata
  @requiredKey
  String fileDescriptionUrl;

  /// Object containing information about the latest revision to the file
  @requiredKey
  FileRevision latest;

  /// Information about the file's preferred preview format
  @requiredKey
  Format preferred;

  /// Information about the file's original format
  @requiredKey
  Format original;

  File(
      {this.title,
      this.fileDescriptionUrl,
      this.latest,
      this.preferred,
      this.original});

  factory File.fromJson(Map<String, dynamic> json) => _$FileFromJson(json);
}

@JsonSerializable()
class FileWithThumbnail extends File {
  /// Information about the file's thumbnail format
  @requiredKey
  Format thumbnail;

  FileWithThumbnail(
      {String title,
      String fileDescriptionUrl,
      FileRevision latest,
      Format preferred,
      Format original,
      this.thumbnail})
      : super(
          title: title,
          fileDescriptionUrl: fileDescriptionUrl,
          latest: latest,
          preferred: preferred,
          original: original,
        );

  factory FileWithThumbnail.fromJson(Map<String, dynamic> json) =>
      _$FileWithThumbnailFromJson(json);
}

class FileFuture
    with FutureProxy<FileWithThumbnail>
    implements Future<FileWithThumbnail> {
  /// File title
  Future<String> title;

  /// URL for the page describing the file, including license information and other metadata
  Future<String> fileDescriptionUrl;

  /// Object containing information about the latest revision to the file
  Future<FileRevision> latest;

  /// Information about the file's preferred preview format
  Future<Format> preferred;

  /// Information about the file's original format
  Future<Format> original;

  /// Information about the file's thumbnail format
  Future<Format> thumbnail;

  FileFuture(Wiki wiki, String title) {
    future = wiki
        .requestJson(path: 'file/$title')
        .then((value) => FileWithThumbnail.fromJson(value));

    this.title = future.then((value) => value.title);
    fileDescriptionUrl = future.then((value) => value.fileDescriptionUrl);
    latest = future.then((value) => value.latest);
    preferred = future.then((value) => value.preferred);
    original = future.then((value) => value.original);
    thumbnail = future.then((value) => value.thumbnail);
  }
}
