import 'dart:convert';
import 'package:torrent_parser/torrent_parser.dart';
import 'package:test/test.dart';

void main() {
  group('basic tests', () {
    TorrentParser torrentParser;

    setUp(() async {
      torrentParser = await TorrentParser.fromFile('test/multi.torrent');
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
      expect(TorrentParser.fromString('d3:agei123e4:name4:xutye').parseAny(),
          equals({'name': 'xuty', 'age': 123}));
    });

    test('Parse list', () {
      expect(
          TorrentParser.fromString('l3:agei123e4:name4:xutye').parseAny(),
          equals([
            'age',
            123,
            'name',
            'xuty',
          ]));
    });

    test('Parse string', () {
      expect(TorrentParser.fromString('11:hello world').parseAny(),
          equals('hello world'));
      expect(TorrentParser.fromString('4:hola').parseAny(), equals('hola'));
      expect(() => TorrentParser.fromString('100:haha').parseAny(),
          throwsA(equals('broken string at 4')));
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

  group('TorrentInfo tests', () {});
}
