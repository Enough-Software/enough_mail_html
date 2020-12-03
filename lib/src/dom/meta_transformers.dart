import '../enough_mail_html_base.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:html/dom.dart';

class ViewPortTransformer implements DomTransformer {
  static final Element _viewPortMetaElement = Element.html(
      '<meta name="viewport" content="width=device-width, initial-scale=1.0">');

  const ViewPortTransformer();

  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    final metaElements = document.getElementsByTagName('meta');
    var viewportNeedsToBeAdded = true;
    for (final metaElement in metaElements) {
      if (metaElement.attributes['name'] == 'viewport') {
        viewportNeedsToBeAdded = false;
        metaElement.attributes['content'] =
            'width=device-width, initial-scale=1.0';
      }
    }
    if (viewportNeedsToBeAdded) {
      document.head.append(_viewPortMetaElement);
    }
  }
}
