import 'package:rest_wiki/wiki.dart';

Future<void> main() async {
  final wiki = await Wiki.fromUrl('https://en.wikipedia.org/w/');
  print(await wiki.page('Jupiter').id);
}
