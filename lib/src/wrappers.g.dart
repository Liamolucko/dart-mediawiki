// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrappers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileMetadata _$FileMetadataFromJson(Map<String, dynamic> json) {
  return $checkedNew('FileMetadata', json, () {
    $checkKeys(json, requiredKeys: const ['url']);
    final val = FileMetadata(
      size: $checkedConvert(json, 'size', (v) => v as int),
      width: $checkedConvert(json, 'width', (v) => v as int),
      height: $checkedConvert(json, 'height', (v) => v as int),
      duration:
          $checkedConvert(json, 'duration', (v) => (v as num)?.toDouble()),
      url: $checkedConvert(json, 'url', (v) => v as String),
    );
    return val;
  });
}

Thumbnail _$ThumbnailFromJson(Map<String, dynamic> json) {
  return $checkedNew('Thumbnail', json, () {
    $checkKeys(json, requiredKeys: const ['url', 'mimetype']);
    final val = Thumbnail(
      size: $checkedConvert(json, 'size', (v) => v as int),
      width: $checkedConvert(json, 'width', (v) => v as int),
      height: $checkedConvert(json, 'height', (v) => v as int),
      duration:
          $checkedConvert(json, 'duration', (v) => (v as num)?.toDouble()),
      url: $checkedConvert(json, 'url', (v) => v as String),
      mimetype: $checkedConvert(json, 'mimetype', (v) => v as String),
    );
    return val;
  });
}

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return $checkedNew('SearchResult', json, () {
    $checkKeys(json, requiredKeys: const ['id', 'key', 'title', 'excerpt']);
    final val = SearchResult(
      id: $checkedConvert(json, 'id', (v) => v as int),
      key: $checkedConvert(json, 'key', (v) => v as String),
      title: $checkedConvert(json, 'title', (v) => v as String),
      excerpt: $checkedConvert(json, 'excerpt', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String),
      thumbnail: $checkedConvert(
          json,
          'thumbnail',
          (v) =>
              v == null ? null : Thumbnail.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}

PageRevision _$PageRevisionFromJson(Map<String, dynamic> json) {
  return $checkedNew('PageRevision', json, () {
    $checkKeys(json, requiredKeys: const ['id', 'timestamp']);
    final val = PageRevision(
      id: $checkedConvert(json, 'id', (v) => v as int),
      timestamp: $checkedConvert(json, 'timestamp', (v) => v as String),
    );
    return val;
  });
}

License _$LicenseFromJson(Map<String, dynamic> json) {
  return $checkedNew('License', json, () {
    $checkKeys(json, requiredKeys: const ['url', 'title']);
    final val = License(
      url: $checkedConvert(json, 'url', (v) => v as String),
      title: $checkedConvert(json, 'title', (v) => v as String),
    );
    return val;
  });
}

Language _$LanguageFromJson(Map<String, dynamic> json) {
  return $checkedNew('Language', json, () {
    $checkKeys(json, requiredKeys: const ['code', 'name', 'key', 'title']);
    final val = Language(
      code: $checkedConvert(json, 'code', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      key: $checkedConvert(json, 'key', (v) => v as String),
      title: $checkedConvert(json, 'title', (v) => v as String),
    );
    return val;
  });
}

Format _$FormatFromJson(Map<String, dynamic> json) {
  return $checkedNew('Format', json, () {
    $checkKeys(json, requiredKeys: const ['url', 'mediatype']);
    final val = Format(
      size: $checkedConvert(json, 'size', (v) => v as int),
      width: $checkedConvert(json, 'width', (v) => v as int),
      height: $checkedConvert(json, 'height', (v) => v as int),
      duration:
          $checkedConvert(json, 'duration', (v) => (v as num)?.toDouble()),
      url: $checkedConvert(json, 'url', (v) => v as String),
      mediatype: $checkedConvert(json, 'mediatype', (v) => v as String),
    );
    return val;
  });
}

User _$UserFromJson(Map<String, dynamic> json) {
  return $checkedNew('User', json, () {
    $checkKeys(json, requiredKeys: const ['id', 'name']);
    final val = User(
      id: $checkedConvert(json, 'id', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
    );
    return val;
  });
}
