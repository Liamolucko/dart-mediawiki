import 'lib/wiki.dart';

Future main() async {
  final wiki = await Wiki.fromUrl('https://en.wikipedia.org/w/');
  await for (var revision
      in wiki.page('Jupiter').history(filter: 'bot', limit: 100)) {
    print(revision.user.name);
  }
}
