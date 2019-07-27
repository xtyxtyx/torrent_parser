Utility to parse .torrent files. ![ci][ci]

To parse bencoded data consider using https://pub.dev/packages/torrent_bencode

## Standalone executable

Installation
```sh
# install with pub
pub global activate torrent_parser
```

Usage
```json
tp ./test/multi.torrent

{
  "encoding": "UTF-8",
  "announce": "http://tr.bangumi.moe:6969/announce",
  "created by": "rin-pr/0.5.1",
  "creation date": 1494251524,
  "info": {
    "name": "[Sakurato.sub] [New Game!] [13_OVA] [GB] [720P]",
    "length": null,
    "piece length": 131072,
    "files": [
      {
        "length": 132320705,
        "path": [
          "[Sakurato.sub] [New Game!] [13_OVA] [GB] [720P].mp4"
        ]
      },
      {
        "length": 1385432,
        "path": [
          "桜都字幕组招募中～.jpg"
        ]
      }
    ],
    "pieces": [
      "a5641ed0f4be619742fd56bc3fe3f4454c5ebed6",
      "37a1f42bf736ea12eb76b0ccb53bf505d3babb15",
      "7b46a960cfd74c491a77a1335462f9311ff6d9ae",
      "ef84bb9f06d96b9bf532134095b311c1ab3e7087",
      "0be60c3fa15f8981186b4931ca6151ad4e39fd96",
      "cba2ca15ed8b110c57f52f0d58767abf73eca3a4",
      "cbfcb848de4ab11db8f375516371c24c2a739320",
      "e22f05de6ec9b31e336bc409f591b8a9ee4fb725",
      ...
    ]
  }
}
```

## Usage

An example:

```dart
import 'package:torrent_parser/torrent_parser.dart';

main() async {
  final parser = await TorrentParser.fromFile('test/multi.torrent');
  // or final parser = TorrentParser.fromString('d8:announce27:http://example.com/announcee');

  final torrent = parser.parse();
  // or final torrent = parser.tryParse();
  // which return null rather than throw an exception on failure

  print(torrent);
  // Output:
  //
  // {
  //   "encoding": "UTF-8",
  //   "announce": "http://tr.bangumi.moe:6969/announce",
  //   "info": {
  //     "length": null,
  //     "name": "[Sakurato.sub] [New Game!] [13_OVA] [GB] [720P]",
  //     "files": [
  //       {
  //         "length": 132320705,
  //         "path": [
  //           "[Sakurato.sub] [New Game!] [13_OVA] [GB] [720P].mp4"
  //         ]
  //       },
  //       ...
  //     ],
  //     "piece length": 131072,
  //     "pieces": [
  //       "a5641ed0f4be619742fd56bc3fe3f4454c5ebed6",
  //       "37a1f42bf736ea12eb76b0ccb53bf505d3babb15",
  //       "cba2ca15ed8b110c57f52f0d58767abf73eca3a4",
  //       "cbfcb848de4ab11db8f375516371c24c2a739320",
  //       ...
  //     ]
  //   },
  //   "announce-list": [
  //     [
  //       "http://tr.bangumi.moe:6969/announce"
  //     ],
  //     [
  //       "http://t.nyaatracker.com/announce"
  //     ],
  //     ...
  //   ],
  //   "created by": "rin-pr/0.5.1",
  //   "creation date": 1494251524
  // }

  print(torrent.announce);
  // Output:
  //
  // http://tr.bangumi.moe:6969/announce

  print(torrent.info.name);
  // Output:
  //
  // [Sakurato.sub] [New Game!] [13_OVA] [GB] [720P]
}

```

## Test

Run tests with:
```
pub run test
```

## References

- http://bittorrent.org/beps/bep_0000.html
- http://bittorrent.org/beps/bep_0003.html

## Features and bugs

Please file feature requests and bugs at the [Github issues][tracker].

[tracker]: https://github.com/xtyxtyx/torrent_parser
[ci]: https://travis-ci.org/xtyxtyx/torrent_parser.svg?branch=master