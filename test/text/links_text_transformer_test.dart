import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:enough_mail_html/src/text/links_text_transformer.dart';
import 'package:test/test.dart';

void main() {
  String transform(String input) {
    const transformer = LinksTextTransformer();
    return transformer.transform(
        input, MimeMessage(), TransformConfiguration.standardConfiguration);
  }

  group('Test https links', () {
    test('https in the middle', () {
      const input = 'hello https://domain.com?query=12329183921kskd world.';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a> world.');
    });
    test('https at the end', () {
      const input = 'hello https://domain.com?query=12329183921kskd';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>');
    });
    test('https with linebreak n', () {
      const input = 'hello https://domain.com?query=12329183921kskd\nworld';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>\nworld');
    });
    test('https with linebreak rn', () {
      const input = 'hello https://domain.com?query=12329183921kskd\r\nworld';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>\r\nworld');
    });

    test('https with dot at end', () {
      const input = 'hello https://domain.com.';

      expect(transform(input),
          'hello <a href="https://domain.com">https://domain.com</a>.');
    });
    test('https with colon at end', () {
      const input = 'hello https://domain.com,';

      expect(transform(input),
          'hello <a href="https://domain.com">https://domain.com</a>,');
    });
    test('https with semicolon at end', () {
      const input = 'hello https://domain.com;';

      expect(transform(input),
          'hello <a href="https://domain.com">https://domain.com</a>;');
    });

    test('https url with dot at end', () {
      const input = 'hello https://domain.com?query=12329183921kskd.';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>.');
    });
    test('https url with colon at end', () {
      const input = 'hello https://domain.com?query=12329183921kskd,';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>,');
    });
    test('https url with semicolon at end', () {
      const input = 'hello https://domain.com?query=12329183921kskd;';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">https://domain.com?query=12329183921kskd</a>;');
    });

    test('https url with + in the URL', () {
      const input = 'look here https://domain.com/query+123+9183921kskd';

      expect(transform(input),
          'look here <a href="https://domain.com/query+123+9183921kskd">https://domain.com/query+123+9183921kskd</a>');
    });
  });

  group('Test www domains', () {
    test('in the middle', () {
      const input = 'hello www.domain.com?query=12329183921kskd world.';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a> world.');
    });
    test('at the end', () {
      const input = 'hello www.domain.com?query=12329183921kskd';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>');
    });
    test('with linebreak n', () {
      const input = 'hello www.domain.com?query=12329183921kskd\nworld';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>\nworld');
    });
    test('with linebreak rn', () {
      const input = 'hello www.domain.com?query=12329183921kskd\r\nworld';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>\r\nworld');
    });

    test('with dot at end', () {
      const input = 'hello www.domain.com.';

      expect(transform(input),
          'hello <a href="https://www.domain.com">www.domain.com</a>.');
    });
    test('with colon at end', () {
      const input = 'hello www.domain.com,';

      expect(transform(input),
          'hello <a href="https://www.domain.com">www.domain.com</a>,');
    });
    test('with semicolon at end', () {
      const input = 'hello www.domain.com;';

      expect(transform(input),
          'hello <a href="https://www.domain.com">www.domain.com</a>;');
    });

    test('url with dot at end', () {
      const input = 'hello www.domain.com?query=12329183921kskd.';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>.');
    });
    test('url with colon at end', () {
      const input = 'hello www.domain.com?query=12329183921kskd,';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>,');
    });
    test('url with semicolon at end', () {
      const input = 'hello www.domain.com?query=12329183921kskd;';

      expect(transform(input),
          'hello <a href="https://www.domain.com?query=12329183921kskd">www.domain.com?query=12329183921kskd</a>;');
    });
  });

  group('Test just domains', () {
    test('in the middle', () {
      const input = 'hello domain.com?query=12329183921kskd world.';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a> world.');
    });
    test('at the end with parameters', () {
      const input = 'hello domain.com?query=12329183921kskd';
      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>');
    });
    test('at the end without parameters', () {
      const input = 'hello domain.com';

      expect(transform(input),
          'hello <a href="https://domain.com">domain.com</a>');
    });
    test('with linebreak n', () {
      const input = 'hello domain.com?query=12329183921kskd\nworld';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>\nworld');
    });
    test('with linebreak rn', () {
      const input = 'hello domain.com?query=12329183921kskd\r\nworld';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>\r\nworld');
    });

    test('with dot at end', () {
      const input = 'hello domain.com.';

      expect(transform(input),
          'hello <a href="https://domain.com">domain.com</a>.');
    });
    test('with colon at end', () {
      const input = 'hello domain.com,';

      expect(transform(input),
          'hello <a href="https://domain.com">domain.com</a>,');
    });
    test('with semicolon at end', () {
      const input = 'hello domain.com;';

      expect(transform(input),
          'hello <a href="https://domain.com">domain.com</a>;');
    });

    test('url with dot at end', () {
      const input = 'hello domain.com?query=12329183921kskd.';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>.');
    });
    test('url with colon at end', () {
      const input = 'hello domain.com?query=12329183921kskd,';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>,');
    });
    test('url with semicolon at end', () {
      const input = 'hello domain.com?query=12329183921kskd;';

      expect(transform(input),
          'hello <a href="https://domain.com?query=12329183921kskd">domain.com?query=12329183921kskd</a>;');
    });
  });

  group('Email addresses', () {
    test('email', () {
      const input = 'hello some.one@domain.org,';

      expect(transform(input), 'hello some.one@domain.org,');
    });
  });

  group('Full texts', () {
    test('full text 1', () {
      const input = '''hello some.one@domain.org,
If you need help, please consider our domain.org-support which
is available here: https://kb.domain.org/display/SUPPORT/get+support+here

I hope you enjoy our service

Yours
  Support Team of domain.org
https://domain.org
Some text here
  ''';

      const expected = '''hello some.one@domain.org,
If you need help, please consider our <a href="https://domain.org">domain.org</a>-support which
is available here: <a href="https://kb.domain.org/display/SUPPORT/get+support+here">https://kb.domain.org/display/SUPPORT/get+support+here</a>

I hope you enjoy our service

Yours
  Support Team of <a href="https://domain.org">domain.org</a>
<a href="https://domain.org">https://domain.org</a>
Some text here
  ''';

      expect(transform(input), expected);
    });
  });
}
