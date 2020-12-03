import 'dart:convert';

import '../enough_mail_html_base.dart';
import 'package:enough_mail/mime_message.dart';
import 'package:html/dom.dart';

class ImageTransformer implements DomTransformer {
  const ImageTransformer();
  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    final imageElements = document.getElementsByTagName('img');
    for (final imageElement in imageElements) {
      final src = imageElement.attributes['src'];
      if (src != null) {
        if (src.startsWith('cid:')) {
          final cid = src.substring('cid:'.length);
          final part = message.getPartWithContentId(cid);
          if (part != null) {
            final contentType = part.getHeaderContentType();
            final mediaType = contentType.mediaType.text;
            final binary = part.decodeContentBinary();
            final base64Data = base64Encode(binary);
            imageElement.attributes['src'] =
                'data:$mediaType;base64,$base64Data';
          }
        } else if (src.startsWith('http')) {
          if (configuration.blockExternalImages) {
            imageElement.attributes.remove('src');
          } else if (src.startsWith('http:')) {
            // always at least enforce HTTPS images:
            final url = src.substring('http:'.length);
            imageElement.attributes['src'] = 'https:$url';
          }
        }
      }
    }
  }
}
