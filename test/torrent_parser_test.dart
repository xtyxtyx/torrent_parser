import 'package:convert/convert.dart';
import 'package:torrent_parser/torrent_parser.dart';
import 'package:test/test.dart';

void main() {
  group('basic tests', () {
    TorrentParser singleFileTorrent;
    TorrentParser multiFileTorrent;

    setUp(() async {
      singleFileTorrent = await TorrentParser.fromFile('test/single.torrent');
      multiFileTorrent = await TorrentParser.fromFile('test/multi.torrent');
    });

    test('parse', () {
      var torrent = singleFileTorrent.parse();
      expect(torrent.infoHash,
          equals(hex.decode('f5b31b1bd67bf65fe97be298ec7c473cb2e3e201')));
      expect(torrent.info.totalLength, equals(1478492160));

      torrent = multiFileTorrent.parse();
      expect(torrent.infoHash,
          equals(hex.decode('01f3144d118a8863ac14880802e96ec8a61ca82b')));
      expect(torrent.info.totalLength, equals(133706137));
    });

    test('Parse int', () {
      expect(TorrentParser.fromString('i123e').parseAny(), equals(123));
      expect(TorrentParser.fromString('i456e').parseAny(), equals(456));
      expect(TorrentParser.fromString('i-123e').parseAny(), equals(-123));
    });

    test('Parse dict', () {
      expect(TorrentParser.fromString('d3:agei123e4:name4:xutye').parseAny(),
          equals({'name': 'xuty'.runes.toList(), 'age': 123}));
    });

    test('Parse list', () {
      expect(
          TorrentParser.fromString('l3:agei123e4:name4:xutye').parseAny(),
          equals([
            'age'.runes.toList(),
            123,
            'name'.runes.toList(),
            'xuty'.runes.toList(),
          ]));
    });

    test('Parse string', () {
      expect(TorrentParser.fromString('11:hello world').parseAny(),
          equals('hello world'.runes.toList()));
      expect(TorrentParser.fromString('4:hola').parseAny(),
          equals('hola'.runes.toList()));
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
