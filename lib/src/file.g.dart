// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileRevision _$FileRevisionFromJson(Map<String, dynamic> json) {
  return $checkedNew('FileRevision', json, () {
    $checkKeys(json, requiredKeys: const ['timestamp', 'user']);
    final val = FileRevision(
      $checkedConvert(json, 'timestamp', (v) => v as String),
      $checkedConvert(json, 'user',
          (v) => v == null ? null : User.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}

File _$FileFromJson(Map<String, dynamic> json) {
  return $checkedNew('File', json, () {
    $checkKeys(json, requiredKeys: const [
      'title',
      'file_description_url',
      'latest',
      'preferred',
      'original'
    ]);
    final val = File(
      title: $checkedConvert(json, 'title', (v) => v as String),
      fileDescriptionUrl:
          $checkedConvert(json, 'file_description_url', (v) => v as String),
      latest: $checkedConvert(
          json,
          'latest',
          (v) => v == null
              ? null
              : FileRevision.fromJson(v as Map<String, dynamic>)),
      preferred: $checkedConvert(json, 'preferred',
          (v) => v == null ? null : Format.fromJson(v as Map<String, dynamic>)),
      original: $checkedConvert(json, 'original',
          (v) => v == null ? null : Format.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  }, fieldKeyMap: const {'fileDescriptionUrl': 'file_description_url'});
}

FileWithThumbnail _$FileWithThumbnailFromJson(Map<String, dynamic> json) {
  return $checkedNew('FileWithThumbnail', json, () {
    $checkKeys(json, requiredKeys: const [
      'title',
      'file_description_url',
      'latest',
      'preferred',
      'original',
      'thumbnail'
    ]);
    final val = FileWithThumbnail(
      title: $checkedConvert(json, 'title', (v) => v as String),
      fileDescriptionUrl:
          $checkedConvert(json, 'file_description_url', (v) => v as String),
      latest: $checkedConvert(
          json,
          'latest',
          (v) => v == null
              ? null
              : FileRevision.fromJson(v as Map<String, dynamic>)),
      preferred: $checkedConvert(json, 'preferred',
          (v) => v == null ? null : Format.fromJson(v as Map<String, dynamic>)),
      original: $checkedConvert(json, 'original',
          (v) => v == null ? null : Format.fromJson(v as Map<String, dynamic>)),
      thumbnail: $checkedConvert(json, 'thumbnail',
          (v) => v == null ? null : Format.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  }, fieldKeyMap: const {'fileDescriptionUrl': 'file_description_url'});
}
