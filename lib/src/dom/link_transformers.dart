import '../enough_mail_html_base.dart';
import 'package:enough_mail/mime.dart';
import 'package:html/dom.dart';

class EnsureRelationNoreferrerTransformer extends DomTransformer {
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
