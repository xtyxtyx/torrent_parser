
import 'dart:convert';
import 'package:torrent_parser/torrent_parser.dart';
import 'package:test/test.dart';

void main() {

  group('basic tests', () {
    TorrentParser torrentParser;

    setUp(() async {
      torrentParser = await TorrentParser.fromFile('test/multi.torrent');
    });

    test('Get data length', () {
      expect(torrentParser.dataLength, equals(22231));
    });

    test('parse', () {
      expect(torrentParser.parse(), anything);
      // print(torrentParser.parse().raw['info'].keys);
    });

    test('Parse int', () {
      expect(TorrentParser.fromString('i123e').parseAny(), equals(123));
      expect(TorrentParser.fromString('i456e').parseAny(), equals(456));
      expect(TorrentParser.fromString('i-123e').parseAny(), equals(-123));
    });

    test('Parse dict', () {
      expect(TorrentParser.fromString('d3:agei123e4:name4:xutye').parseAny(), equals({
        'name': 'xuty',
        'age': 123
      }));
    });

    test('Parse list', () {
      expect(TorrentParser.fromString('l3:agei123e4:name4:xutye').parseAny(), equals([
        'age', 123, 'name', 'xuty',
      ]));
    });

    test('Parse string', () {
      expect(TorrentParser.fromString('11:hello world').parseAny(), equals('hello world'));
      expect(TorrentParser.fromString('4:hola').parseAny(), equals('hola'));
      expect(() => TorrentParser.fromString('100:haha').parseAny(), throwsA(equals('broken string at 4')));
    });

  });

  group('reader tests', () {
    DataReader reader;

    setUp(() {
      final data = 'hello world'.runes.toList();
      reader = DataReader(data);
    });

    test('takeString', () {
      expect(reader.peekString(5), equals('hello'));
      expect(reader.peekString(5), equals('hello'));
      expect(reader.peekString(1), equals('h'));
      expect(reader.takeString(5), equals('hello'));
      expect(reader.takeString(), equals(' '));
      expect(reader.takeString(5), equals('world'));
      expect(reader.takeString(), equals(null));
      expect(reader.takeString(5), equals(null));
    });

    test('match', () {
      expect(reader.match('hello'), equals('hello'));
      expect(reader.match('hello'), equals('hello'));
      expect(reader.match('hola'), equals(null));
    });

    test('matches', () {
      expect(reader.matches('hello'), equals(true));
      expect(reader.matches('hello'), equals(true));
      expect(reader.matches('hola'), equals(false));
    });

    test('readInt', () {
      final reader = DataReader.fromString(('123abc456def-789'));
      expect(reader.readInt(), equals(123));
      expect(reader.expect('abc'), anything);
      expect(reader.readInt(), equals(456));
      expect(reader.expect('def'), anything);
      expect(reader.readInt(), equals(-789));
      expect(reader.atEOF, equals(true));
    });
    

    test('atEOf', () {
      expect(reader.atEOF, equals(false));
      expect(reader.takeString(11), equals('hello world'));
      expect(reader.atEOF, equals(true));
    });

    test('expect', () {
      expect(() => reader.expect('hola'), throwsA(equals('hola expected at 0')));
      expect(reader.expect('hello'), equals('hello'));
      expect(reader.expect(' '), equals(' '));
      expect(reader.expect('world'), equals('world'));
      expect(() => reader.expect('sekai'), throwsA(equals('sekai expected at 11')));
    });
  });

  group('torrent data tests', () {

    // test('toString', () {
    //   final data = TorrentData.fromJson({
    //     'announce': 'some tracker'
    //   });
    //   expect(data.toString(), equals(
    //     '{"announce":"some tracker"}'
    //   ));
    // });

  });

  group('TorrentInfo tests', () {

    test('_splitPieces', () {
      expect(TorrentInfo.splitPieces('b667507d95b114bfd2866a6863e3ad95a89e52a5ecf6ee1e13eede3a7133b8f3571860973f49b94b'), equals([
        'b667507d95b114bfd286', '6a6863e3ad95a89e52a5',
        'ecf6ee1e13eede3a7133', 'b8f3571860973f49b94b'
      ]));
    });

  });
}
