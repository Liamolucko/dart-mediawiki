# dart-mediawiki
### Dart bindings for the Mediawiki REST API, which can also be polyfilled by its traditional Actions API.

## Usage

```dart
import 'package:rest_wiki/wiki.dart';

main() async {
  final wiki = await Wiki.fromUrl('https://en.wikipedia.org/w/');
  print(await wiki.page('Jupiter').id); // 38930
}
```
