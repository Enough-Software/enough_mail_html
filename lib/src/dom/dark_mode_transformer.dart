import 'package:enough_mail/src/mime_message.dart';
import 'package:enough_mail_html/src/enough_mail_html_base.dart';
import 'package:html/dom.dart';

/// Forces dark mode also for older browsers
class DarkModeTransformer extends DomTransformer {
  const DarkModeTransformer();

  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    if (configuration.enableDarkMode) {
      ensureDocumentHeadIsAvailable(document);
      final style = Element.html(
          '<style type="text/css">body {color: #FFFFFF; margin: 4px;}</style>');
      document.head!.append(style);
    }
  }
}
