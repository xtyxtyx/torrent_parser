Utility to parse .torrent files.

## Usage

An example:

```dart
import 'package:torrent_parser/torrent_parser.dart';

main() async {
  final parser = await TorrentParser.fromFile('test/multi.torrent');
  print(parser.parse());
}

```

## Features and bugs

Please file feature requests and bugs at the [Github issues][tracker].

[tracker]: https://github.com/xtyxtyx/torrent_parser
