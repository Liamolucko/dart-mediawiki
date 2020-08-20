import 'package:rest_wiki/src/errors.dart';
import 'package:rest_wiki/wiki.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final wiki = await Wiki.fromUrl('https://en.wikipedia.org/w/api.php');

  test('basic usage doesn\'t throw errors', () async {
    final page = wiki.page('Jupiter');
    await page.fetch();
    await page.html;
  });

  test('throws on invalid page', () async {
    expect(wiki.page('nonexistent page').fetch(), throwsA(isA<ApiException>()));
  });
}
