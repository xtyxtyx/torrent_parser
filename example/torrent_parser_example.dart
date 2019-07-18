import 'package:torrent_parser/torrent_parser.dart';

main() async {
  final parser = await TorrentParser.fromFile('test/multi.torrent');
  print(parser.parse());
}
