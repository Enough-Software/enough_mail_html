import 'package:enough_mail_html/src/text/convert_tags_text_transformer.dart';
import 'package:enough_mail_html/src/text/linebreak_text_transformer.dart';
import 'package:enough_mail_html/src/text/links_text_transformer.dart';
import 'package:enough_mail_html/src/text/merge_image_text_transformer.dart';

import 'dom/image_transformers.dart';
import 'dom/link_transformers.dart';
import 'dom/meta_transformers.dart';
import 'dom/script_transformers.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

/// Contains the configuration for all transformations.
class TransformConfiguration {
  /// Should external images be blocked?
  final bool blockExternalImages;

  /// The text that should be displayed in an otherwise empty message.
  final String emptyMessageText;

  /// The template for converting a plain text message into a HTML document.
  ///
  /// Requires to have the string `{text}` into which the plain text message is pasted, e.g. `<p>{text}</p>`.
  final String plainTextHtmlTemplate;

  /// The maximum width for embedded images. It make sense to limit this to reduce the generated HTML size.
  final int maxImageWidth;

  /// The list of DOM transformers being used
  final List<DomTransformer> domTransformers;

  /// The list of text transfomers that are used before a plain text message without HTML part is converted into HTML
  final List<TextTransformer> textTransfomers;

  /// Optional custom values, `null` unless specified.
  final Map<String, dynamic> customValues;

  const TransformConfiguration(
      this.blockExternalImages,
      this.emptyMessageText,
      this.maxImageWidth,
      this.domTransformers,
      this.textTransfomers,
      this.plainTextHtmlTemplate,
      this.customValues);

  /// Provides easy access to a standard configuation that does not block external images.
  static const TransformConfiguration standardConfiguration =
      TransformConfiguration(
          false,
          standardEmptyMessageText,
          standardMaxImageWidth,
          standardDomTransformers,
          standardTextTransformers,
          standardPlainTextHtmlTemplate,
          null);

  /// Provides an easy optopn to customize a configuration.
  ///
  /// Any specified [customDomTransformers] or [customTextTransformers] are being appended to the standard transformers.
  static TransformConfiguration create({
    bool blockExternalImages,
    String emptyMessageText,
    int maxImageWidth,
    String plainTextHtmlTemplate,
    List<DomTransformer> customDomTransformers,
    List<TextTransformer> customTextTransfomers,
    Map<String, dynamic> customValues,
  }) {
    final domTransformers = customDomTransformers != null
        ? [...standardDomTransformers, ...customDomTransformers]
        : standardDomTransformers;
    final textTransformers = customTextTransfomers != null
        ? [...standardTextTransformers, ...customTextTransfomers]
        : standardTextTransformers;
    maxImageWidth ??= standardMaxImageWidth;
    return TransformConfiguration(
        blockExternalImages ?? false,
        emptyMessageText ?? standardEmptyMessageText,
        maxImageWidth,
        domTransformers,
        textTransformers,
        plainTextHtmlTemplate ?? standardPlainTextHtmlTemplate,
        customValues);
  }

  static const int standardMaxImageWidth = null;
  static const String standardPlainTextHtmlTemplate = '<p>{text}</p>';
  static const String standardEmptyMessageText =
      'This message has no contents.';
  static const List<DomTransformer> standardDomTransformers = [
    ViewPortTransformer(),
    RemoveScriptTransformer(),
    ImageTransformer(),
    EnsureRelationNoreferrerTransformer(),
  ];

  static const List<TextTransformer> standardTextTransformers = [
    ConvertTagsTextTransformer(),
    MergeAttachedImageTextTransformer(),
    LinksTextTransformer(),
    LineBreakTextTransformer(),
  ];
}

/// Transforms the HTML DOM.
abstract class DomTransformer {
  const DomTransformer();

  /// Uses the `DOM` [document] and specified [message] to transform the `document`.
  ///
  /// All changes will be visible to subsequenc transformers.
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration);
}

class MimeMessageTransformer {
  final TransformConfiguration configuration;

  MimeMessageTransformer(this.configuration);

  String transformPlainText(String plainText, MimeMessage message) {
    for (final textTransformer in configuration.textTransfomers) {
      plainText = textTransformer.transform(plainText, message, configuration);
    }
    return plainText;
  }

  void transformDocument(Document document, MimeMessage message) {
    for (final domTransformer in configuration.domTransformers) {
      domTransformer.process(document, message, configuration);
    }
  }

  Document toDocument(MimeMessage message) {
    var html = message.decodeTextHtmlPart();
    if (html == null) {
      var textPart = message.decodeTextPlainPart();
      if (textPart == null) {
        if (message.hasInlineParts()) {
          textPart = '';
        } else {
          textPart = configuration.emptyMessageText;
        }
      } else {
        textPart = transformPlainText(textPart, message);
      }
      html =
          configuration.plainTextHtmlTemplate.replaceFirst('{text}', textPart);
    }
    final document = parse(html);
    // if (configuration.blockExternalImages) {
    //   blockExternalImageProcessor.process(document, this);
    // }
    transformDocument(document, message);
    //TODO integrate other inline parts

    return document;
  }

  String toHtml(MimeMessage message) {
    return toDocument(message).outerHtml;
  }
}

/// Transforms plain text messages.
abstract class TextTransformer {
  const TextTransformer();
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration);
}

/// Extends the MimeMessage with the [transformToHtml] method.
extension HtmlTransform on MimeMessage {
  /// Transforms this message to Document.
  ///
  /// Set [blockExternalImages] to `true` in case external images should be blocked.
  /// Optionally specify the [maxImageWidth] to set the maximum width for embedded images.
  /// Optionally specify the [emptyMessageText] for messages that contain no other content.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation - in that case other parameters are ignored.
  Document transformToDocument({
    bool blockExternalImages,
    int maxImageWidth,
    String emptyMessageText,
    TransformConfiguration transformConfiguration,
  }) {
    transformConfiguration ??= TransformConfiguration.create(
        blockExternalImages: blockExternalImages,
        emptyMessageText: emptyMessageText,
        maxImageWidth: maxImageWidth);
    final transformer = MimeMessageTransformer(transformConfiguration);
    return transformer.toDocument(this);
  }

  /// Transforms this message to HTML code.
  ///
  /// Set [blockExternalImages] to `true` in case external images should be blocked.
  /// Optionally specify the [maxImageWidth] to set the maximum width for embedded images.
  /// Optionally specify the [emptyMessageText] for messages that contain no other content.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation - in that case other parameters are ignored.
  String transformToHtml({
    bool blockExternalImages,
    int maxImageWidth,
    String emptyMessageText,
    TransformConfiguration transformConfiguration,
  }) {
    final document = transformToDocument(
        blockExternalImages: blockExternalImages,
        maxImageWidth: maxImageWidth,
        emptyMessageText: emptyMessageText,
        transformConfiguration: transformConfiguration);
    return document.outerHtml;
  }

  /// Transforms this message to the innter BODY HTML code.
  ///
  /// Set [blockExternalImages] to `true` in case external images should be blocked.
  /// Optionally specify the [maxImageWidth] to set the maximum width for embedded images.
  /// Optionally specify the [emptyMessageText] for messages that contain no other content.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation - in that case other parameters are ignored.
  String transformToBodyInnerHtml({
    bool blockExternalImages,
    int maxImageWidth,
    String emptyMessageText,
    TransformConfiguration transformConfiguration,
  }) {
    final document = transformToDocument(
        blockExternalImages: blockExternalImages,
        maxImageWidth: maxImageWidth,
        emptyMessageText: emptyMessageText,
        transformConfiguration: transformConfiguration);
    return document.body.innerHtml;
  }

  /// Quotes the body of this message for editing HTML.
  ///
  /// Optionally specify the [quoteHeaderTemplate], defaults to `MailConventions.defaultReplyHeaderTemplate`, for forwarding you can use the `MailConventions.defaultForwardHeaderTemplate`.
  /// Set [blockExternalImages] to `true` in case external images should be blocked.
  /// Optionally specify the [maxImageWidth] to set the maximum width for embedded images.
  /// Optionally specify the [emptyMessageText] for messages that contain no other content.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation - in that case other parameters are ignored.
  String quoteToHtml({
    String quoteHeaderTemplate,
    bool blockExternalImages,
    int maxImageWidth,
    String emptyMessageText,
    TransformConfiguration transformConfiguration,
  }) {
    quoteHeaderTemplate ??= MailConventions.defaultReplyHeaderTemplate;
    final quoteHeader = MessageBuilder.fillTemplate(quoteHeaderTemplate, this)
        .replaceAll('&', '&amp;')
        .replaceAll('>', '&gt;')
        .replaceAll('<', '&lt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\r\n', '<br/>');
    final document = transformToDocument(
        blockExternalImages: blockExternalImages,
        maxImageWidth: maxImageWidth,
        emptyMessageText: emptyMessageText,
        transformConfiguration: transformConfiguration);
    return '<p><br/></p><blockquote>$quoteHeader<br/>${document.body.innerHtml}</blockquote>';
  }
}
