import 'package:enough_mail/mime.dart';

import '../enough_mail_html_base.dart';

/// Detects URLs in texts and links them
class LinksTextTransformer extends TextTransformer {
  /// Creates a new link transformer
  const LinksTextTransformer();

  /// A regex for detecting schemes such as `https://` or `sftp://`.
  static final RegExp schemeRegEx = RegExp(r'[a-z]{3,6}://');

  /// not a perfect but good enough regular expression to match URLs in text.
  // /It also matches a space at the beginning and a dot at the end,
  /// so this is filtered out manually in the found matches
  static final RegExp linkRegEx = RegExp(
      r'(([a-z]{3,6}:\/\/)|(^|\s))([a-zA-Z0-9\-]+\.)+[a-z]{2,13}([\?\/]+[\.\?\=\&\%\/\w\+\-]*)?');

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    final matches = linkRegEx.allMatches(text);
    if (matches.isEmpty) {
      return text;
    }
    final buffer = StringBuffer();
    var end = 0;
    for (final match in matches) {
      if (match.end < text.length && text[match.end] == '@') {
        // this is an email address, abort abort! ;-)
        continue;
      }
      final originalGroup = match.group(0)!;
      final group = originalGroup.trimLeft();
      final start = match.start + originalGroup.length - group.length;
      buffer.write(text.substring(end, start));
      final endsWithDot = group.endsWith('.');
      final urlText =
          endsWithDot ? group.substring(0, group.length - 1) : group;
      buffer.write('<a href="');
      if (!group.startsWith(schemeRegEx)) {
        buffer.write('https://');
      }
      buffer
        ..write(urlText)
        ..write('">')
        ..write(urlText)
        ..write('</a>');
      end = endsWithDot ? match.end - 1 : match.end;
    }
    if (end < text.length) {
      buffer.write(text.substring(end));
    }
    return buffer.toString();
  }
}
