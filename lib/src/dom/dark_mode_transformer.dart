import 'package:enough_mail/src/mime_message.dart';
import 'package:enough_mail_html/src/enough_mail_html_base.dart';
import 'package:html/dom.dart';

class DarkModeTransformer extends DomTransformer {
  const DarkModeTransformer();

  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    if (configuration.enableDarkMode) {
      ensureDocumentHeadIsAvailable(document);
      final style = Element.html('<style>body {color: #FFFFFF;}</style>');
      document.head!.append(style);
    }
  }
}
