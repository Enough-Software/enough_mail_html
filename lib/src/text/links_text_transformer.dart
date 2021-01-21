import 'package:enough_mail/mime_message.dart';

import '../enough_mail_html_base.dart';
import 'text_search.dart';

class LinksTextTransformer extends TextTransformer {
  const LinksTextTransformer();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    final search = FlexibleEndTextSearchIterator('https://', text,
        endSearchPatterns: [' ', '\r\n', '\n'],
        endSearchPatternCanBeEndOfText: true);
    String nextLink;
    while ((nextLink = search.next()) != null) {
      if (nextLink.endsWith('.') ||
          nextLink.endsWith(',') ||
          nextLink.endsWith(';') ||
          nextLink.endsWith(':')) {
        nextLink = nextLink.substring(0, nextLink.length - 1);
      }
      text = text.replaceFirst(nextLink, '<a href="$nextLink">$nextLink</a>');
    }
    return text;
  }
}
