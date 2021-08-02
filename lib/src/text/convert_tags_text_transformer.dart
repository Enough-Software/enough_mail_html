import 'package:enough_mail/mime.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

class ConvertTagsTextTransformer implements TextTransformer {
  const ConvertTagsTextTransformer();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    return text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  }
}
