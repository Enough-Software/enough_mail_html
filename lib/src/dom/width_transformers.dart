import 'package:enough_mail/mime.dart';
import 'package:html/dom.dart';

import '../enough_mail_html_base.dart';

/// Removes any width attributes that are larger than the maxWidth
class WidthTransformer extends DomTransformer {
  /// Creates a [WidthTransformer]
  const WidthTransformer();

  @override
  void process(
    Document document,
    MimeMessage message,
    TransformConfiguration configuration,
  ) {
    final body = document.body;
    if (body != null) {
      _processElement(body, message, configuration);
    }
    final styleElements = document.getElementsByTagName('style');
    for (final styleElement in styleElements) {
      var text = styleElement.text;
      int startIndex;
      while ((startIndex = text.indexOf('-webkit-background-size:')) != -1) {
        final endIndex =
            text.indexOf(';', startIndex + '-webkit-background-size:'.length);
        if (endIndex == -1) {
          break;
        }
        text = startIndex == 0
            ? text.substring(endIndex + 1)
            : text.substring(0, startIndex) + text.substring(endIndex + 1);
      }
      styleElement.text = text;
    }
  }

  void _processElement(
    Element element,
    MimeMessage message,
    TransformConfiguration configuration,
  ) {
    final widthAttribute = element.attributes['width'];
    if (widthAttribute != null) {
      final width = int.tryParse(widthAttribute);
      if (width != null) {
        final maxWidth = configuration.attributeWidthMax;
        if (width > maxWidth) {
          element.attributes.remove('width');
        }
      }
    }
    final styleAttribute = element.attributes['style'];
    if (styleAttribute != null) {
      final widthIndex = styleAttribute.indexOf('width:');
      if (widthIndex != -1) {
        final semicolonIndex =
            styleAttribute.indexOf(';', widthIndex + 'width:'.length);
        if (semicolonIndex != -1) {
          final newStyleAttribute = widthIndex == 0
              ? styleAttribute.substring(semicolonIndex + 1)
              : styleAttribute.substring(0, widthIndex) +
                  styleAttribute.substring(semicolonIndex + 1);
          element.attributes['style'] = newStyleAttribute;
        }
      }
    }
    for (final element in element.children) {
      _processElement(element, message, configuration);
    }
  }
}
