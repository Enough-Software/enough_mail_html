import 'dart:convert';

import 'package:enough_mail/mime.dart';
import 'package:html/dom.dart';
import 'package:image/image.dart' as img;

import '../enough_mail_html_base.dart';

/// Resolves nested images
class ImageTransformer extends DomTransformer {
  /// Creates a new image transformer
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
            final contentType = part.getHeaderContentType()!;
            final data =
                toImageData(part, contentType.mediaType, configuration);
            imageElement.attributes['src'] = data;
            final maxImageWidth = configuration.maxImageWidth;
            if (maxImageWidth != null &&
                imageElement.attributes['width'] != null &&
                imageElement.attributes['height'] != null) {
              final width = int.tryParse(imageElement.attributes['width']!);
              final height = int.tryParse(imageElement.attributes['height']!);
              if (width != null && width > maxImageWidth && height != null) {
                final factor = maxImageWidth / width;
                imageElement.attributes['width'] = maxImageWidth.toString();
                imageElement.attributes['height'] =
                    (height * factor).floor().toString();
                final styleAttribute = imageElement.attributes['style'];
                if (styleAttribute != null &&
                    styleAttribute.contains('width')) {
                  imageElement.attributes.remove('style');
                }
              }
            }
            if (imageElement.parent?.localName != 'a') {
              final linkCid =
                  Uri.encodeComponent(cid.substring(1, cid.length - 1));
              final anchor = Element.html('<a href="cid://$linkCid"></a>')
                ..append(Element.html(imageElement.outerHtml));
              imageElement.replaceWith(anchor);
            }
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
      //TODO inline elements should be added at their respective positions
      //and not necessary below the text
      if (info.isImage) {
        final cid = info.cid;
        if (cid == null || !usedContentIds.contains(cid)) {
          final part = message.getPart(info.fetchId);
          if (part != null) {
            final data = toImageData(part, info.mediaType, configuration);
            final imageElement = Element.html(
                '<a href="fetch://${info.fetchId}"><img src="$data" alt="${info.fileName}" /></a>');
            document.body!.append(imageElement);
          }
        }
      }
    }
  }

  /// Converts the media in the given mime [part] into a base-64 representation
  static String toImageData(
    MimePart part,
    MediaType? mediaType,
    TransformConfiguration configuration,
  ) {
    var binary = part.decodeContentBinary()!;
    var mediaTypeText = mediaType?.text ?? 'image/png';
    if (configuration.maxImageWidth != null && binary.length > 64 * 1024) {
      final image = img.decodeImage(binary)!;
      if (image.width > configuration.maxImageWidth!) {
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
