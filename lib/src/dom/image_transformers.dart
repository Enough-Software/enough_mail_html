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
    final usedContentIds = <String>[];
    for (final imageElement in imageElements) {
      final src = imageElement.attributes['src'];
      if (src != null) {
        if (src.startsWith('cid:')) {
          final cid = src.substring('cid:'.length);
          final part = message.getPartWithContentId(cid);
          if (part != null) {
            usedContentIds.add(cid);
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
    // integrate other inline images:
    final inlineInfos =
        message.findContentInfo(disposition: ContentDisposition.inline);

    for (final info in inlineInfos) {
      if (info.isImage) {
        final part = message.getPart(info.fetchId);
        if (!usedContentIds.contains(part.getHeaderValue('content-id'))) {
          final binary = part.decodeContentBinary();
          final base64Data = base64Encode(binary);
          final mediaType = info.mediaType?.text ?? 'image/png';
          final imageElement = Element.html(
              '<img src="data:$mediaType;base64,$base64Data" alt="${info.fileName}" />');
          document.body.append(imageElement);
        }
      }
    }
  }
}
