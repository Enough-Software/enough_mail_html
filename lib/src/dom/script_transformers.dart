import '../enough_mail_html_base.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:html/dom.dart';

class RemoveScriptTransformer extends DomTransformer {
  const RemoveScriptTransformer();
  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    final scriptElements = document.getElementsByTagName('script');
    for (final scriptElement in scriptElements) {
      scriptElement.remove();
      //TODO remove onClick etc handlers?
    }
  }
}
