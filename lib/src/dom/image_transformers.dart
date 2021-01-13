import 'dart:convert';
import '../enough_mail_html_base.dart';
import 'package:image/image.dart' as img;
import 'package:html/dom.dart';
import 'package:enough_mail/mime_message.dart';
import 'package:enough_mail/media_type.dart';

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
          var cid = src.substring('cid:'.length);
          if (!cid.startsWith('<')) {
            cid = '<$cid>';
          }
          final part = message.getPartWithContentId(cid);
          if (part != null) {
            usedContentIds.add(cid);
            final contentType = part.getHeaderContentType();
            final data =
                toImageData(part, contentType.mediaType, configuration);
            imageElement.attributes['src'] = data;
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
        final cid = info.cid;
        if (!usedContentIds.contains(cid)) {
          final part = message.getPart(info.fetchId);
          final data = toImageData(part, info.mediaType, configuration);
          final imageElement =
              Element.html('<img src="$data" alt="${info.fileName}" />');
          document.body.append(imageElement);
        }
      }
    }
  }

  static String toImageData(MimePart part, MediaType mediaType,
      TransformConfiguration configuration) {
    var binary = part.decodeContentBinary();
    var mediaTypeText = mediaType?.text ?? 'image/png';
    if (configuration.maxImageWidth != null && binary.length > 64 * 1024) {
      final image = img.decodeImage(binary);
      if (image.width > configuration.maxImageWidth) {
        final resized =
            img.copyResize(image, width: configuration.maxImageWidth);
        final reducedBinary = img.encodePng(resized);
        // print(
        //     'reduced from ${binary.length} to ${reducedBinary.length}  / ${reducedBinary.length / binary.length}');
        binary = reducedBinary;
        mediaTypeText = 'image/png';
      }
    }
    final base64Data = base64Encode(binary);
    return 'data:$mediaTypeText;base64,$base64Data';
  }
}
