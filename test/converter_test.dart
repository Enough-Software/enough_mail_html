import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:test/test.dart';

void main() {
  group('Test plain text conversion', () {
    test('short', () {
      final html = '<p>Hello World</p>';
      expect(HtmlToPlainTextConverter.convert(html), 'Hello World');
    });

    test('shortWithAppendedText', () {
      final html = '<p>Hello World.</p> Here is some more.';
      expect(HtmlToPlainTextConverter.convert(html),
          'Hello World. Here is some more.');
    });

    test('shortWithPrependedText', () {
      final html = 'Here is some more. <p>Hello World.</p>';
      expect(HtmlToPlainTextConverter.convert(html),
          'Here is some more. Hello World.');
    });

    test('shortWithAppendedAndPrependedText', () {
      final html =
          'Here is some more1. <p>Hello World.</p> Here is some more2.';
      expect(HtmlToPlainTextConverter.convert(html),
          'Here is some more1. Hello World. Here is some more2.');
    });

    test('long', () {
      final html = '''<p>Hello World</p>
<p><div style="font-weight: bold;">This</div> is a message.</p>
<blockquote><p>quoted text!</p></blockquote>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello World
This is a message.
>quoted text!''');
    });

    test('with pre', () {
      final html = '''<p>Hello World</p>
<p><div style="font-weight: bold;">This</div> is a message.</p>
<blockquote><p>quoted text!</p></blockquote>
<pre>
<p>This html should be</p>
<blockquote>kept</blockquote>
</pre>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello World
This is a message.
>quoted text!

<p>This html should be</p>
<blockquote>kept</blockquote>
''');
    });

    test('with html entities', () {
      final html = '''<p>Hello &amp; World&#128540;</p>
<p><div style="font-weight: bold;">This</div> is a &phi; message&#169;&#x00A9;&#xA9;.</p>
<blockquote><p>quoted text!</p></blockquote>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello & World😜
This is a φ message©©©.
>quoted text!''');
    });

    test('with html entities and <pre>', () {
      final html = '''<p>Hello &amp; World&#128540;</p>
<p><div style="font-weight: bold;">This</div> is a &phi; message&#169;&#x00A9;&#xA9;.</p>
<pre>
<p>This html &amp; should be</p>
<blockquote>kept</blockquote>
</pre>
<blockquote><p>quoted text!</p></blockquote>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello & World😜
This is a φ message©©©.

<p>This html &amp; should be</p>
<blockquote>kept</blockquote>

>quoted text!''');
    });
  });
}
