import 'package:enough_mail/mime.dart';
import 'package:html/dom.dart';

import '../enough_mail_html_base.dart';

/// Ensures all links to have a noopener and noreferrer relation
class EnsureRelationNoreferrerTransformer extends DomTransformer {
  /// Creates a new link relation transformer
  const EnsureRelationNoreferrerTransformer();

  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    final linkElements = document.getElementsByTagName('a');
    for (final linkElement in linkElements) {
      linkElement.attributes['rel'] = 'noopener noreferrer';
    }
  }
}
