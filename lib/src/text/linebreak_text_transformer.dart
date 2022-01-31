import 'package:enough_mail/mime.dart';

import '../enough_mail_html_base.dart';

/// Replaces line breaks into HTML line breaks.
class LineBreakTextTransformer extends TextTransformer {
  /// Creates a new line break transformer
  const LineBreakTextTransformer();

  @override
  String transform(String text, MimeMessage message,
          TransformConfiguration configuration) =>
      text.replaceAll('\r\n', '<br/>').replaceAll('\n', '<br/>');
}
