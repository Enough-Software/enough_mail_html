import 'package:enough_mail_html/src/text/links_text_transformer.dart';
import 'package:test/test.dart';

void main() {
  group('Test https links', () {
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

    test('https with dot at end', () {
      final input = 'hello https://domain.com.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com">https://domain.com</a>.');
    });
    test('https with colon at end', () {
      final input = 'hello https://domain.com,';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com">https://domain.com</a>,');
    });
    test('https with semicolon at end', () {
      final input = 'hello https://domain.com;';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com">https://domain.com</a>;');
    });

    test('https url with dot at end', () {
      final input = 'hello https://domain.com?query=12329183921kskd.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>.');
    });
    test('https url with colon at end', () {
      final input = 'hello https://domain.com?query=12329183921kskd,';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>,');
    });
    test('https url with semicolon at end', () {
      final input = 'hello https://domain.com?query=12329183921kskd;';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>;');
    });
  });

  group('Test www domains', () {
    test('in the middle', () {
      final input = 'hello www.domain.com?query=12329183921kskd world.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a> world.');
    });
    test('at the end', () {
      final input = 'hello www.domain.com?query=12329183921kskd';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>');
    });
    test('with linebreak n', () {
      final input = 'hello www.domain.com?query=12329183921kskd\nworld';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>\nworld');
    });
    test('with linebreak rn', () {
      final input = 'hello www.domain.com?query=12329183921kskd\r\nworld';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>\r\nworld');
    });

    test('with dot at end', () {
      final input = 'hello www.domain.com.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com">www.domain.com</a>.');
    });
    test('with colon at end', () {
      final input = 'hello www.domain.com,';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com">www.domain.com</a>,');
    });
    test('with semicolon at end', () {
      final input = 'hello www.domain.com;';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com">www.domain.com</a>;');
    });

    test('url with dot at end', () {
      final input = 'hello www.domain.com?query=12329183921kskd.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>.');
    });
    test('url with colon at end', () {
      final input = 'hello www.domain.com?query=12329183921kskd,';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>,');
    });
    test('url with semicolon at end', () {
      final input = 'hello www.domain.com?query=12329183921kskd;';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>;');
    });
  });

  group('Test just domains', () {
    test('in the middle', () {
      final input = 'hello domain.com?query=12329183921kskd world.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a> world.');
    });
    test('at the end', () {
      final input = 'hello domain.com?query=12329183921kskd';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>');
    });
    test('with linebreak n', () {
      final input = 'hello domain.com?query=12329183921kskd\nworld';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>\nworld');
    });
    test('with linebreak rn', () {
      final input = 'hello domain.com?query=12329183921kskd\r\nworld';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>\r\nworld');
    });

    test('with dot at end', () {
      final input = 'hello domain.com.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com">domain.com</a>.');
    });
    test('with colon at end', () {
      final input = 'hello domain.com,';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com">domain.com</a>,');
    });
    test('with semicolon at end', () {
      final input = 'hello domain.com;';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com">domain.com</a>;');
    });

    test('url with dot at end', () {
      final input = 'hello domain.com?query=12329183921kskd.';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>.');
    });
    test('url with colon at end', () {
      final input = 'hello domain.com?query=12329183921kskd,';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>,');
    });
    test('url with semicolon at end', () {
      final input = 'hello domain.com?query=12329183921kskd;';
      final transformer = LinksTextTransformer();
      expect(transformer.transform(input, null, null),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>;');
    });
  });
}
