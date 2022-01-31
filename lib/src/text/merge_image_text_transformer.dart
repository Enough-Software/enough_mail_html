import 'package:enough_mail/mime.dart';

import '../dom/image_transformers.dart';
import '../enough_mail_html_base.dart';
import 'text_search.dart';

/// Detects mentions of CID references in texts and includes matching images
class MergeAttachedImageTextTransformer extends TextTransformer {
  /// Create a new image transformer
  const MergeAttachedImageTextTransformer();

  @override
  String transform(
    String text,
    MimeMessage message,
    TransformConfiguration configuration,
  ) {
    final search = TextSearchIterator('[cid:', text, endSearchPattern: ']');
    String? nextImageDefinition;
    while ((nextImageDefinition = search.next()) != null) {
      var cid = nextImageDefinition!
          .substring('[cid:'.length, nextImageDefinition.length - 2);
      if (!cid.startsWith('<')) {
        cid = '<$cid>';
      }
      final part = message.getPartWithContentId(cid);
      if (part != null) {
        final contentType = part.getHeaderContentType();
        final mediaType = contentType?.mediaType;
        final data =
            ImageTransformer.toImageData(part, mediaType, configuration);
        final linkCid = Uri.encodeComponent(cid.substring(1, cid.length - 1));
        // ignore: parameter_assignments
        text = text.replaceFirst(nextImageDefinition,
            '<a href="cid://$linkCid"><img src="$data" alt="${part.getHeaderContentDisposition()?.filename}"/></a>');
      }
    }
    return text;
  }
}
