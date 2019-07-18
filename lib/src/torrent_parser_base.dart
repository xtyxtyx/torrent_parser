import 'dart:io';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:json_annotation/json_annotation.dart';

import 'data_reader.dart';

part 'torrent_parser_base.g.dart';

/// TorrentParser is the workhorse of this library.
///
/// Give it a piece of data and then call the `parse` method,
/// it will produce an object representing the torrent.
class TorrentParser {
  DataReader _reader;

  /// dataLength is the length of the torrent file in bytes.
  get dataLength => _reader.dataLength;

  /// Creates a TorrentParser from binary data
  TorrentParser(List<int> data) : _reader = DataReader(data);

  /// Creates a TorrentParser from string. Mainly used for test purpose.
  TorrentParser.fromString(String data)
      : _reader = DataReader(data.runes.toList());

  /// Creates a TorrentParser by reading .torrent file specified by `path`
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
    _reader.reset();
    final dict = _readDict();
    _reader.expectEOF();
    return TorrentData.fromJson(dict);
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
    _reader.reset();
    return _readNext();
  }

  dynamic _readNext() {
    if (_reader.matches('d')) {
      return _readDict();
    }
    if (_reader.matches('i')) {
      return _readInt();
    }
    if (_reader.matches('l')) {
      return _readList();
    }
    if (_reader.matches(RegExp(r'[0-9]'))) {
      return _readString();
    }
    if (_reader.atEOF) {
      return null;
    }

    throw 'd, i, l or <number> expected at ${_reader.pos}';
  }

  String _readString() {
    final len = _reader.readInt();
    _reader.expect(':');
    final str = _reader.takeString(len);
    if (str == null) {
      throw 'broken string at ${_reader.pos}';
    }
    return str;
  }

  List<dynamic> _readList() {
    final result = <dynamic>[];
    _reader.expect('l');
    while (!_reader.matches('e')) {
      final value = _readNext();
      result.add(value);
    }
    _reader.expect('e');
    return result;
  }

  Map<String, dynamic> _readDict() {
    final result = <String, dynamic>{};
    _reader.expect('d');
    while (!_reader.matches('e')) {
      final key = _readString();
      final value = _readNext();
      result[key] = value;
    }
    _reader.expect('e');
    return result;
  }

  int _readInt() {
    _reader.expect('i');
    final result = _reader.readInt();
    _reader.expect('e');
    return result;
  }
}

@JsonSerializable()
class FileInfo {
  /// length is the length of this file in bytes.
  int length;

  /// "A list of UTF-8 encoded strings corresponding
  /// to subdirectory names, the last of which is the
  /// actual file name (a zero length list is an error case)."
  ///
  /// From: http://bittorrent.org/beps/bep_0003.html
  List<String> path;

  FileInfo();

  factory FileInfo.fromJson(Map<String, dynamic> json) =>
      _$FileInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FileInfoToJson(this);
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
  @JsonKey(name: 'piece length')
  int pieceLength;

  /// pieces maps to a string whose length is a multiple of 20.
  /// It is to be subdivided into strings of length 20,
  /// each of which is the SHA1 hash of the piece at the corresponding index.
  @JsonKey(fromJson: splitPieces)
  List<String> pieces;

  TorrentInfo();

  factory TorrentInfo.fromJson(Map<String, dynamic> json) =>
      _$TorrentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TorrentInfoToJson(this);

  static List<String> splitPieces(String raw) {
    const piece_len = 20;
    final result = <String>[];
    for (var i = 0; i < raw.length; i += piece_len) {
      final str = raw.substring(i, i + piece_len);
      result.add(hex.encode(str.runes.toList()));
    }
    return result;
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
  @JsonKey(name: 'announce-list')
  List<List<String>> announceList;

  /// software that creates this torrent
  @JsonKey(name: 'created by')
  String createdBy;

  /// timestamp when this torrent was created.
  @JsonKey(name: 'creation date')
  int creationDate;

  TorrentData();

  factory TorrentData.fromJson(Map<String, dynamic> json) =>
      _$TorrentDataFromJson(json);

  Map<String, dynamic> toJson() => _$TorrentDataToJson(this);

  @override
  String toString() {
    final data = toJson();
    return JsonEncoder.withIndent('  ').convert(data);
  }
}
