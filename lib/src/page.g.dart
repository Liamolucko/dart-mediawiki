// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageMetadata _$PageMetadataFromJson(Map<String, dynamic> json) {
  return $checkedNew('PageMetadata', json, () {
    $checkKeys(json, requiredKeys: const ['id', 'title']);
    final val = PageMetadata(
      id: $checkedConvert(json, 'id', (v) => v as int),
      title: $checkedConvert(json, 'title', (v) => v as String),
    );
    return val;
  });
}
