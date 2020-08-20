// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Revision _$RevisionFromJson(Map<String, dynamic> json) {
  return $checkedNew('Revision', json, () {
    $checkKeys(json,
        requiredKeys: const ['id', 'user', 'timestamp', 'size', 'minor']);
    final val = Revision(
      id: $checkedConvert(json, 'id', (v) => v as int),
      user: $checkedConvert(json, 'user',
          (v) => v == null ? null : User.fromJson(v as Map<String, dynamic>)),
      timestamp: $checkedConvert(json, 'timestamp', (v) => v as String),
      comment: $checkedConvert(json, 'comment', (v) => v as String),
      size: $checkedConvert(json, 'size', (v) => v as int),
      delta: $checkedConvert(json, 'delta', (v) => v as int),
      minor: $checkedConvert(json, 'minor', (v) => v as bool),
    );
    return val;
  });
}

RevisionWithPage _$RevisionWithPageFromJson(Map<String, dynamic> json) {
  return $checkedNew('RevisionWithPage', json, () {
    $checkKeys(json, requiredKeys: const [
      'id',
      'user',
      'timestamp',
      'size',
      'minor',
      'page'
    ]);
    final val = RevisionWithPage(
      id: $checkedConvert(json, 'id', (v) => v as int),
      user: $checkedConvert(json, 'user',
          (v) => v == null ? null : User.fromJson(v as Map<String, dynamic>)),
      timestamp: $checkedConvert(json, 'timestamp', (v) => v as String),
      comment: $checkedConvert(json, 'comment', (v) => v as String),
      size: $checkedConvert(json, 'size', (v) => v as int),
      delta: $checkedConvert(json, 'delta', (v) => v as int),
      minor: $checkedConvert(json, 'minor', (v) => v as bool),
      page: $checkedConvert(
          json,
          'page',
          (v) => v == null
              ? null
              : PageMetadata.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}
