import 'package:enough_mail/mime.dart';
import 'package:html/dom.dart';

import '../enough_mail_html_base.dart';

/// Forces dark mode also for older browsers
class DarkModeTransformer extends DomTransformer {
  /// Create a new dark mode transformer
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
