import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:convert/convert.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:torrent_bencode/torrent_bencode.dart';

import 'utils.dart';

/// TorrentParser is the workhorse of this library.
///
/// Give it a piece of data and then call the `parse` method,
/// it will produce an object representing the torrent.
class TorrentParser {
  List<int> _data;

  /// Creates a TorrentParser from bencoded bytes.
  TorrentParser(this._data);

  /// Creates a TorrentParser from string. Mainly used for test purpose.
  TorrentParser.fromString(String str) : _data = str.runes.toList();

  /// Creates a TorrentParser from .torrent file specified by `path`
  ///
  /// Note that this static method returns a Future and therefore needs `await`.
  static Future<TorrentParser> fromFile(String path) async {
    final data = await File(path).readAsBytes();
    return TorrentParser(data);
  }

  /// Parse the torrent file data and returns the result.
  ///
  /// This method throws an exception in case the parsing process failed.
  TorrentData parse() {
    final dict = bDecoder.convert(_data);
    assert(dict is Map);
    return TorrentData.fromRawData(dict);
  }

  /// tryParse is equivalent to `parse`
  /// except that tryParse wiil return null when failed rather than throw an exception
  TorrentData tryParse() {
    try {
      return parse();
    } catch (_) {
      return null;
    }
  }

  /// parseAny can parse any bencoding objects
  /// inclding strings, ints, lists and dictionaries
  /// whereas `parse` can merely parse a dictionary.
  dynamic parseAny() {
    return bDecoder.convert(_data);
  }
}

@JsonSerializable()
class FileInfo {
  /// length is the length of this file in bytes.
  int length;

  /// A list of UTF-8 encoded strings corresponding
  /// to subdirectory names, the last of which is the
  /// actual file name (a zero length list is an error case).
  List<String> path;

  FileInfo();

  FileInfo.fromRawData(Map<String, dynamic> data) {
    length = data['length'];
    path = data['path']?.map<String>((item) => utf8.decode(item))?.toList();
  }

  Map<String, dynamic> toJson() => {
        'length': length,
        'path': path,
      };
}

@JsonSerializable()
class TorrentInfo {
  /// The length of the file, absent if this torrent contains
  /// multiple files.
  int length;

  /// The name of the file, or the directory name when this torrent
  /// contains multiple files.
  String name;

  /// A list of FileInfo, absent if the torrent contains
  /// only one file.
  List<FileInfo> files;

  /// pieceLength maps to the number of bytes in each piece the
  /// file is split into. For the purposes of transfer, files
  /// are split into fixed-size pieces which are all the same length
  /// except for possibly the last one which may be truncated. piece
  /// length is almost always a power of two, most commonly
  /// 2^18 = 256 K (BitTorrent prior to version 3.2 uses 2 20 = 1 M as default).
  int pieceLength;

  /// pieces maps to a string whose length is a multiple of 20.
  /// It is to be subdivided into strings of length 20,
  /// each of which is the SHA1 hash of the piece at the corresponding index.
  List<List<int>> pieces;

  TorrentInfo();

  TorrentInfo.fromRawData(Map<String, dynamic> data) {
    length = data['length'];
    pieceLength = data['piece length'];
    name = utf8.decode(data['name']);
    pieces = splitList(data['pieces'], 20);
    files = (data['files'] as List<dynamic>)
        ?.map((file) => FileInfo.fromRawData(file))
        ?.toList();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'length': length,
        'piece length': pieceLength,
        'files': files,
        'pieces': pieces?.map(hex.encode)?.toList(),
      };

  int get totalLength {
    if (length != null) return length;
    return files.fold(0, (length, file) => length + file.length);
  }
}

@JsonSerializable()
class TorrentData {
  /// encoding of the torrent
  String encoding;

  /// announce is the URL of the tracker.
  String announce;

  /// TorrentInfo
  TorrentInfo info;

  /// a list of trackers.
  List<List<String>> announceList;

  /// software that creates this torrent
  String createdBy;

  /// timestamp when this torrent was created.
  int creationDate;

  List<int> infoHash;

  TorrentData();

  TorrentData.fromRawData(Map<String, dynamic> data) {
    print(data.keys);
    creationDate = data['creation date'];
    createdBy =
        data['created by'] == null ? null : utf8.decode(data['created by']);
    announce = data['announce'] == null ? null : utf8.decode(data['announce']);
    announceList = data['announce-list'] == null
        ? null
        : List<List<String>>.from((data['announce-list'] as List)
            .map((tier) => List<Uint8List>.from(tier).map(utf8.decode).toList())
            .toList());
    encoding = data['encoding'] == null ? null : utf8.decode(data['encoding']);
    info = data['info'] == null ? null : TorrentInfo.fromRawData(data['info']);
    infoHash = data['info'] == null
        ? null
        : sha1.convert(bEncoder.convert(data['info'])).bytes;
  }

  Map<String, dynamic> toJson() => {
        'encoding': encoding,
        'announce': announce,
        'created by': createdBy,
        'creation date': creationDate,
        'announce-list': announceList,
        'info': info.toJson(),
      };

  @override
  String toString() {
    final data = toJson();
    return JsonEncoder.withIndent('  ').convert(data);
  }
}
