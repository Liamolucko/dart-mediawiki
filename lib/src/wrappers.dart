// Wrappers for data without any additional functionality

import 'package:json_annotation/json_annotation.dart';

part 'wrappers.g.dart';

const requiredKey = JsonKey(required: true);

@JsonSerializable()
class FileMetadata {
  /// File size in bytes or `null` if not available
  int size;

  /// Maximum recommended image width in pixels or `null` if not available
  int width;

  /// Maximum recommended image height in pixels or `null` if not available
  int height;

  /// Length of the video, audio, or multimedia file or `null` for other media types
  double duration;

  /// URL to download the file
  @requiredKey
  String url;

  FileMetadata({this.size, this.width, this.height, this.duration, this.url});

  factory FileMetadata.fromJson(Map<String, dynamic> json) =>
      _$FileMetadataFromJson(json);
}

@JsonSerializable()
class Thumbnail extends FileMetadata {
  /// Thumbnail [media type](https://en.wikipedia.org/wiki/Media_type)
  @requiredKey
  String mimetype;

  Thumbnail(
      {int size,
      int width,
      int height,
      double duration,
      String url,
      this.mimetype})
      : super(
            size: size,
            width: width,
            height: height,
            duration: duration,
            url: url);

  factory Thumbnail.fromJson(Map<String, dynamic> json) =>
      _$ThumbnailFromJson(json);
}

/// The search result object represents a wiki page matching the requested search.
@JsonSerializable()
class SearchResult {
  /// Page identifier
  @requiredKey
  int id;

  /// Page title in URL-friendly format
  @requiredKey
  String key;

  /// Page title in reading-friendly format
  @requiredKey
  String title;

  /// A few lines giving a sample of page content with search terms highlighted with `<span class=\"searchmatch\">` tags
  @requiredKey
  String excerpt;

  /// Short summary of the page topic based on the corresponding entry on [Wikidata](https://www.wikidata.org/wiki/) or `null` if no entry exists
  String description;

  /// Information about the thumbnail image for the page or `null` if no thumbnail exists.
  Thumbnail thumbnail;

  SearchResult(
      {this.id,
      this.key,
      this.title,
      this.excerpt,
      this.description,
      this.thumbnail});

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}

@JsonSerializable()
class PageRevision {
  /// Revision identifier
  @requiredKey
  int id;

  /// Time of the edit in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format
  @requiredKey
  String timestamp;

  PageRevision({this.id, this.timestamp});

  factory PageRevision.fromJson(Map<String, dynamic> json) =>
      _$PageRevisionFromJson(json);
}

/// Information about the wiki's license
@JsonSerializable()
class License {
  /// URL of the applicable license based on the [$wgRightsUrl](https://www.mediawiki.org/wiki/Manual:$wgRightsUrl) setting
  @requiredKey
  String url;

  /// Name of the applicable license based on the [$wgRightsText](https://www.mediawiki.org/wiki/Manual:$wgRightsText) setting
  @requiredKey
  String title;

  License({this.url, this.title});

  factory License.fromJson(Map<String, dynamic> json) =>
      _$LicenseFromJson(json);
}

@JsonSerializable()
class Language {
  /// Language code. For Wikimedia projects, see the [site matrix on Meta-Wiki](https://meta.wikimedia.org/wiki/Special:SiteMatrix).
  @requiredKey
  String code;

  /// Translated language name
  @requiredKey
  String name;

  /// Translated page title in URL-friendly format
  @requiredKey
  String key;

  /// Translated page title in reading-friendly format
  @requiredKey
  String title;

  Language({this.code, this.name, this.key, this.title});

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);
}

@JsonSerializable()
class Format extends FileMetadata {
  /// The file type, one of: BITMAP, DRAWING, AUDIO, VIDEO, MULTIMEDIA, UNKNOWN, OFFICE, TEXT, EXECUTABLE, ARCHIVE, or 3D
  @requiredKey
  String mediatype;

  Format(
      {int size,
      int width,
      int height,
      double duration,
      String url,
      this.mediatype})
      : super(
            size: size,
            width: width,
            height: height,
            duration: duration,
            url: url);

  factory Format.fromJson(Map<String, dynamic> json) => _$FormatFromJson(json);
}

class Diff {
  /// TODO
  Diff(Map data) {}
}

@JsonSerializable()
class User {
  /// User identifier
  @requiredKey
  int id;

  /// Username
  @requiredKey
  String name;

  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
