import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:test/test.dart';

void main() {
  group('DOM', () {
    setUp(() {});

    test('Parse and adapt documents', () {
      const html = '''
<html>
<body>
  <p>hello world</p>
  <img src="cid:part1" />
  <img src="https://someprovider.com/somefolder/name.png" />
</body>
</html>
      ''';
      final document = parse(html);

      expect(document, isNotNull);
      expect(document.head, isNotNull);
      expect(document.body, isNotNull);
      expect(document.getElementsByTagName('img'), isNotEmpty);
      expect(document.getElementsByTagName('img').length, 2);
      expect(document.getElementsByTagName('img')[0].attributes['src'],
          'cid:part1');
      expect(document.getElementsByTagName('img')[1].attributes['src'],
          'https://someprovider.com/somefolder/name.png');
      expect(document.getElementsByTagName('xxxx'), isEmpty);

      final meta = Element.html('<meta name="viewport" '
          'content="width=device-width, initial-scale=1.0">');
      document.head?.append(meta);
      final imageElements = document.getElementsByTagName('img');
      for (final imageElement in imageElements) {
        final src = imageElement.attributes['src'];
        if (src != null) {
          if (src.startsWith('http')) {
            imageElement.attributes.remove('src');
          }
        }
      }
      //print(document.outerHtml);
    });
  });
}
