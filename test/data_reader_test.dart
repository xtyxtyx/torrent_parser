import 'dart:convert';
import 'package:torrent_parser/src/data_reader.dart';
import 'package:test/test.dart';

void main() {
  group('DataReader tests', () {
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
      expect(
          () => reader.expect('hola'), throwsA(equals('hola expected at 0')));
      expect(reader.expect('hello'), equals('hello'));
      expect(reader.expect(' '), equals(' '));
      expect(reader.expect('world'), equals('world'));
      expect(() => reader.expect('sekai'),
          throwsA(equals('sekai expected at 11')));
    });
  });
}
