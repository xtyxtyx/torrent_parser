// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent_parser_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileInfo _$FileInfoFromJson(Map<String, dynamic> json) {
  return FileInfo()
    ..length = json['length'] as int
    ..path = (json['path'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$FileInfoToJson(FileInfo instance) =>
    <String, dynamic>{'length': instance.length, 'path': instance.path};

TorrentInfo _$TorrentInfoFromJson(Map<String, dynamic> json) {
  return TorrentInfo()
    ..length = json['length'] as int
    ..name = json['name'] as String
    ..files = (json['files'] as List)
        ?.map((e) =>
            e == null ? null : FileInfo.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..pieceLength = json['piece length'] as int
    ..pieces = json['pieces'] == null
        ? null
        : TorrentInfo.splitPieces(json['pieces'] as String);
}

Map<String, dynamic> _$TorrentInfoToJson(TorrentInfo instance) =>
    <String, dynamic>{
      'length': instance.length,
      'name': instance.name,
      'files': instance.files,
      'piece length': instance.pieceLength,
      'pieces': instance.pieces
    };

TorrentData _$TorrentDataFromJson(Map<String, dynamic> json) {
  return TorrentData()
    ..encoding = json['encoding'] as String
    ..announce = json['announce'] as String
    ..info = json['info'] == null
        ? null
        : TorrentInfo.fromJson(json['info'] as Map<String, dynamic>)
    ..announceList = (json['announce-list'] as List)
        ?.map((e) => (e as List)?.map((e) => e as String)?.toList())
        ?.toList()
    ..createdBy = json['created by'] as String
    ..creationDate = json['creation date'] as int;
}

Map<String, dynamic> _$TorrentDataToJson(TorrentData instance) =>
    <String, dynamic>{
      'encoding': instance.encoding,
      'announce': instance.announce,
      'info': instance.info,
      'announce-list': instance.announceList,
      'created by': instance.createdBy,
      'creation date': instance.creationDate
    };
