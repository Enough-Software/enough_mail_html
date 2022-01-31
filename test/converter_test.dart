import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:test/test.dart';

void main() {
  group('Test plain text conversion', () {
    test('short', () {
      const html = '<p>Hello World</p>';
      expect(HtmlToPlainTextConverter.convert(html), 'Hello World');
    });

    test('shortWithAppendedText', () {
      const html = '<p>Hello World.</p> Here is some more.';
      expect(HtmlToPlainTextConverter.convert(html),
          'Hello World. Here is some more.');
    });

    test('shortWithPrependedText', () {
      const html = 'Here is some more. <p>Hello World.</p>';
      expect(HtmlToPlainTextConverter.convert(html),
          'Here is some more. \nHello World.');
    });

    test('shortWithAppendedAndPrependedText', () {
      const html =
          'Here is some more1. <p>Hello World.</p> Here is some more2.';
      expect(HtmlToPlainTextConverter.convert(html),
          'Here is some more1. \nHello World. Here is some more2.');
    });

    test('long', () {
      const html = '''<p>Hello World</p>
<p><div style="font-weight: bold;">This</div> is a message.</p>
<blockquote><p>quoted text!</p></blockquote>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello World\n
This is a message.
>
>quoted text!''');
    });

    test('with pre', () {
      const html = '''<p>Hello World</p>
<p><div style="font-weight: bold;">This</div> is a message.</p>
<blockquote><p>quoted text!</p></blockquote>
<pre>
<p>This html should be</p>
<blockquote>kept</blockquote>
</pre>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello World

This is a message.
>
>quoted text!

<p>This html should be</p>
<blockquote>kept</blockquote>
''');
    });

    test('with html entities', () {
      const html = '''<p>Hello &amp; World&#128540;</p>
<p><div style="font-weight: bold;">This</div> is a &phi; message&#169;&#x00A9;&#xA9;.</p>
<blockquote><p>quoted text!</p></blockquote>''';
      expect(HtmlToPlainTextConverter.convert(html), '''Hello & World😜

This is a φ message©©©.
>
>quoted text!''');
    });

    test('with html entities and <pre>', () {
      const html = '''<p>Hello &amp; World&#128540;</p>
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

>
>quoted text!''');
    });

    test('with line breaks', () {
      const html =
          '''<p>&nbsp;Hello my friend<br><br>How are you doing today?<br><br>I wonder <span style="font-weight: bold;">what</span> happened<br><br></p><p>---<br>Sent with Maily</p>''';
      expect(HtmlToPlainTextConverter.convert(html), ''' Hello my friend

How are you doing today?

I wonder what happened


---
Sent with Maily''');
    });
  });
}
