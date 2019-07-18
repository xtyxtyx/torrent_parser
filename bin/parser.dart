import 'dart:io';

import 'package:torrent_parser/torrent_parser.dart';

const help = '''

Usage:

  tp <path>     Prints torrent information.
  tp -h --help  Prints this help page.
''';

main(List<String> args) async {
  if (args.isEmpty) {
    print(help);
    return 1;
  }

  final arg = args[0];
  if (arg == '--help') {
    print(help);
    return 0;
  }

  if(! await File(arg).exists()) {
    print('Error: file "${arg}" does not exist.');
    print(help);
    return 1;
  } else {
    final parser = await TorrentParser.fromFile(arg);
    print(parser.parse());
    return 0;
  }

  print(help);
  return 1;
}