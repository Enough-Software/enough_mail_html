import 'package:enough_mail/mime_message.dart';

import '../enough_mail_html_base.dart';

class LineBreakTextTransformer extends TextTransformer {
  const LineBreakTextTransformer();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    text = text.replaceAll('\r\n', '<br/>');
    text = text.replaceAll('\n', '<br/>');
    return text;
  }
}
