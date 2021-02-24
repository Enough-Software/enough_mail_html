import 'package:enough_mail/mime_message.dart';

import '../enough_mail_html_base.dart';

class LinksTextTransformer extends TextTransformer {
  static final RegExp schemeRegEx = RegExp(r'[a-z]{3,6}://');
  // not a perfect but good enough regular expression to match URLs in text. It also matches a space at the beginning and a dot at the end,
  // so this is filtered out manually in the found matches
  static final RegExp linkRegEx = RegExp(
      r'(([a-z]{3,6}://)|(^|\s))([a-zA-Z0-9\-]+\.)+[a-z]{2,13}[\.\?\=\&\%\/\w\-]*');
  const LinksTextTransformer();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    final matches = linkRegEx.allMatches(text);
    for (final match in matches) {
      final group = match.group(0).trimLeft();
      final urlText =
          group.endsWith('.') ? group.substring(0, group.length - 1) : group;
      final url = group.startsWith(schemeRegEx) ? urlText : 'https://$urlText';
      text = text.replaceFirst(urlText, '<a href="$url">$urlText</a>');
    }
    return text;
  }
}
