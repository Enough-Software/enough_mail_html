import 'package:enough_mail_html/src/text/links_text_transformer.dart';
import 'package:test/test.dart';

void main() {
  group('Test links', () {
    test('https in the middle', () {
      final input = 'hello https://domain.com?query=12329183921kskd world.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a> world.');
    });
    test('https at the end', () {
      final input = 'hello https://domain.com?query=12329183921kskd';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>');
    });
    test('https with linebreak n', () {
      final input = 'hello https://domain.com?query=12329183921kskd\nworld';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>\nworld');
    });
    test('https with linebreak rn', () {
      final input = 'hello https://domain.com?query=12329183921kskd\r\nworld';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>\r\nworld');
    });
  });
}
