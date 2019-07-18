import 'dart:io';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:convert/convert.dart';

part 'torrent_parser_base.g.dart';

class DataReader {

  final List<int> _data;
  int _pos = 0;

  get _stringData => String.fromCharCodes(_data, _pos);
  get dataLength => _data.length;
  get pos => _pos;
  bool get atEOF => peekString() == null;

  DataReader(List<int> data)
  : _data = data;

  DataReader.fromString(String data)
  : _data = data.runes.toList();
  
  String takeString([int len = 1]) {
    final codes = take(len);
    if (codes == null) return null;
    try {
      return utf8.decode(codes);
    } catch (_) {
      return String.fromCharCodes(codes);
    }
  }

  Iterable<int> take([int len = 1]) {
    final result = peek(len);
    if (result == null) {
      return null;
    }

    _pos += len;
    return result;
  }

  String peekString([int len = 1]) {
    final codes = peek(len);
    return codes != null
      ? String.fromCharCodes(codes)
      : null;
  }

  Iterable<int> peek([int len = 1]) {
    if (_data.length < _pos + len) {
      return null;
    }

    final result = _data.sublist(_pos, _pos + len);
    return result;
  }

  String match(Pattern pattern) {
    final result = pattern.matchAsPrefix(_stringData);
    if (result == null) {
      return null;
    }
    return result.group(0);
  }

  bool matches(Pattern pattern) {
    final result = match(pattern);
    return result != null;
  }

  String expect(Pattern pattern) {
    final result = match(pattern);
    if (result == null) {
      throw '$pattern expected at $_pos';
    }
    _pos += result.length;
    return result;
  }

  void expectEOF() {
    if (!atEOF) {
      throw 'EOF expected at $_pos';
    }
  }

  int readInt() {
    int flag = 1;
    final digits = <String>[];
    if (matches('-')) {
      takeString();
      flag = -1;
    }
    while (matches(RegExp(r'[0-9]'))) {
      digits.add(takeString());
    }
    if (digits.isEmpty) {
      throw '<digit> expected at ${pos}';
    }
    return flag * int.parse(digits.join(''));
  }
  
  void reset() {
    _pos = 0;
  }
}

/// TorrentParser
class TorrentParser {

  DataReader _reader;

  get dataLength => _reader.dataLength;

  
  TorrentParser(List<int> data) 
  : _reader = DataReader(data);

  TorrentParser.fromString(String data) 
  : _reader = DataReader(data.runes.toList());

  static Future<TorrentParser> fromFile(String path) async {
    final data = await File(path).readAsBytes();
    return TorrentParser(data);
  }

  TorrentData parse() {
    _reader.reset();
    final dict = _readDict();
    _reader.expectEOF();
    return TorrentData.fromJson(dict);
  }

  TorrentData tryParse() {
    try {
      return parse();
    } catch (_) {
      return null;
    }
  }

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
    if(str == null) {
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
  
  int length;
  List<String> path;

  FileInfo();

  factory FileInfo.fromJson(Map<String, dynamic> json)
    => _$FileInfoFromJson(json);

  Map<String, dynamic> toJson() 
    => _$FileInfoToJson(this);
}

@JsonSerializable()
class TorrentInfo {

  int length;
  String name;
  List<FileInfo> files;

  @JsonKey(name: 'piece length')
  int pieceLength;

  @JsonKey(fromJson: splitPieces)
  List<String> pieces;

  TorrentInfo();

  factory TorrentInfo.fromJson(Map<String, dynamic> json)
    => _$TorrentInfoFromJson(json);

  Map<String, dynamic> toJson() 
    => _$TorrentInfoToJson(this);
  

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

  String encoding;
  String announce;
  TorrentInfo info;

  @JsonKey(name: 'announce-list')
  List<List<String>> announceList;

  @JsonKey(name: 'created by')
  String createdBy;

  @JsonKey(name: 'creation date')
  int creationDate;

  TorrentData();

  factory TorrentData.fromJson(Map<String, dynamic> json)
    => _$TorrentDataFromJson(json);

  Map<String, dynamic> toJson() 
    => _$TorrentDataToJson(this);

  @override
  String toString() {
    final data = toJson();
    return JsonEncoder.withIndent('  ').convert(data);
  }
}