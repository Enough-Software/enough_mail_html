import 'package:enough_mail/enough_mail.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'converter.dart';
import 'dom/dark_mode_transformer.dart';
import 'dom/image_transformers.dart';
import 'dom/link_transformers.dart';
import 'dom/meta_transformers.dart';
import 'dom/script_transformers.dart';
import 'text/convert_tags_text_transformer.dart';
import 'text/linebreak_text_transformer.dart';
import 'text/links_text_transformer.dart';
import 'text/merge_image_text_transformer.dart';

/// Contains the configuration for all transformations.
class TransformConfiguration {
  /// Creates a new transform configuration
  ///
  /// Compare [TransformConfiguration.create] to have an easier to use
  /// building function.
  const TransformConfiguration({
    required this.domTransformers,
    required this.textTransformers,
    this.maxImageWidth,
    this.blockExternalImages = false,
    this.preferPlainText = false,
    this.enableDarkMode = false,
    this.emptyMessageText = standardEmptyMessageText,
    this.plainTextHtmlTemplate = standardPlainTextHtmlTemplate,
    this.customValues,
  });

  /// Provides an easy option to customize a configuration.
  ///
  /// Any specified [customDomTransformers] or [customTextTransformers]
  /// are being appended to the standard transformers.
  factory TransformConfiguration.create({
    bool blockExternalImages = false,
    bool enableDarkMode = false,
    bool preferPlainText = false,
    String? emptyMessageText,
    int? maxImageWidth = standardMaxImageWidth,
    String plainTextHtmlTemplate = standardPlainTextHtmlTemplate,
    List<DomTransformer>? customDomTransformers,
    List<TextTransformer>? customTextTransformers,
    Map<String, dynamic>? customValues,
  }) {
    final domTransformers = (customDomTransformers != null)
        ? [...standardDomTransformers, ...customDomTransformers]
        : [...standardDomTransformers];
    final textTransformers = (customTextTransformers != null)
        ? [...standardTextTransformers, ...customTextTransformers]
        : standardTextTransformers;
    maxImageWidth ??= standardMaxImageWidth;
    return TransformConfiguration(
      blockExternalImages: blockExternalImages,
      preferPlainText: preferPlainText,
      enableDarkMode: enableDarkMode,
      emptyMessageText: emptyMessageText ?? standardEmptyMessageText,
      maxImageWidth: maxImageWidth,
      domTransformers: domTransformers,
      textTransformers: textTransformers,
      plainTextHtmlTemplate: plainTextHtmlTemplate,
      customValues: customValues,
    );
  }

  /// Should the plain text be used instead of the HTML text?
  final bool preferPlainText;

  /// Should external images be blocked?
  final bool blockExternalImages;

  /// Should a dark mode be enabled?
  /// This might be required for devices with older browser versions
  final bool enableDarkMode;

  /// The text that should be displayed in an otherwise empty message.
  final String emptyMessageText;

  /// The template for converting a plain text message into a HTML document.
  ///
  /// Requires to have the string `{text}` into which the plain
  /// text message is pasted, e.g. `<p>{text}</p>`.
  final String plainTextHtmlTemplate;

  /// The maximum width for embedded images.
  /// It make sense to limit this to reduce the generated HTML size.
  final int? maxImageWidth;

  /// The list of DOM transformers being used
  final List<DomTransformer> domTransformers;

  /// The list of text transfomers that are used
  /// before a plain text message without HTML part is converted into HTML
  final List<TextTransformer> textTransformers;

  /// Optional custom values, `null` unless specified.
  final Map<String, dynamic>? customValues;

  /// Provides easy access to a standard configuation
  /// that does not block external images.
  static const TransformConfiguration standardConfiguration =
      TransformConfiguration(
    blockExternalImages: false,
    preferPlainText: false,
    enableDarkMode: false,
    emptyMessageText: standardEmptyMessageText,
    maxImageWidth: standardMaxImageWidth,
    domTransformers: standardDomTransformers,
    textTransformers: standardTextTransformers,
    plainTextHtmlTemplate: standardPlainTextHtmlTemplate,
  );

  /// The standard maximum image width is `null`, ie not restricted.
  static const int? standardMaxImageWidth = null;

  /// Embeds the plain text in a paragraph
  /// `<p>{text}</p>`
  static const String standardPlainTextHtmlTemplate = '<p>{text}</p>';

  /// Default (English) empty message text
  static const String standardEmptyMessageText =
      'This message has no contents.';

  /// The list of default DOM transformers
  static const List<DomTransformer> standardDomTransformers = [
    ViewPortTransformer(),
    RemoveScriptTransformer(),
    ImageTransformer(),
    EnsureRelationNoreferrerTransformer(),
    DarkModeTransformer(),
  ];

  /// The list of default text transformers
  static const List<TextTransformer> standardTextTransformers = [
    ConvertTagsTextTransformer(),
    MergeAttachedImageTextTransformer(),
    LinksTextTransformer(),
    LineBreakTextTransformer(),
  ];
}

/// Transforms the HTML DOM.
abstract class DomTransformer {
  /// Creates a new DOM transformer
  const DomTransformer();

  /// Transforms the [document] of the [message] using [configuration].
  ///
  /// All changes will be visible to subsequenc transformers.
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration);

  /// Adds a HEAD element if necessary
  void ensureDocumentHeadIsAvailable(Document document) {
    if (document.head == null) {
      document.children.insert(0, Element.html('<head></head>'));
    }
  }
}

/// Transforms MIME messages
class MimeMessageTransformer {
  /// Creates a new mime message transformer
  MimeMessageTransformer(this.configuration);

  /// The configuration used for the transformation
  final TransformConfiguration configuration;

  /// Transforms the plain text [plainText] of the given [message].
  String transformPlainText(String plainText, MimeMessage message) {
    var output = plainText;
    for (final textTransformer in configuration.textTransformers) {
      output = textTransformer.transform(output, message, configuration);
    }
    return output;
  }

  /// Transforms the DOM [document] of the given [message].
  void transformDocument(Document document, MimeMessage message) {
    for (final domTransformer in configuration.domTransformers) {
      domTransformer.process(document, message, configuration);
    }
  }

  /// Transforms the DOM or plain text of the given [message].
  Document toDocument(MimeMessage message) {
    var html =
        configuration.preferPlainText ? null : message.decodeTextHtmlPart();
    if (html == null) {
      var textPart = message.decodeTextPlainPart();
      if (textPart == null && configuration.preferPlainText) {
        textPart = message.decodeTextHtmlPart();
        if (textPart != null) {
          textPart = Document.html(textPart).body?.innerHtml;
          if (textPart != null) {
            textPart = HtmlToPlainTextConverter.convert(textPart);
          }
        }
      }
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
    } else if (configuration.enableDarkMode) {
      // hack to remove any white bgcolor values:
      html = html.replaceAll('bgcolor="#FFFFFF"', '');
      html = html.replaceAll('bgcolor="#ffffff"', '');
    }
    final document = parse(html);
    // if (configuration.blockExternalImages) {
    //   blockExternalImageProcessor.process(document, this);
    // }
    transformDocument(document, message);
    //TODO integrate other inline parts

    return document;
  }

  /// Retrieves the outer HTML of the message after transformation
  String toHtml(MimeMessage message) => toDocument(message).outerHtml;
}

/// Transforms plain text messages.
abstract class TextTransformer {
  /// Createsa new text transformer
  const TextTransformer();

  /// Transforms the given [text] of the [message] using the [configuration ]
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration);
}

/// Extends the MimeMessage with the [transformToHtml] method.
extension HtmlTransform on MimeMessage {
  /// Transforms this message to Document.
  ///
  /// Set [blockExternalImages] to `true` in case external images
  /// should be blocked.
  ///
  /// Set [preferPlainText] to `true` to use plain text instead of the
  /// HTML text.
  ///
  /// Set [enableDarkMode] to `true` to enforce dark mode on devices
  /// with older browsers.
  ///
  /// Optionally specify the [maxImageWidth] to set the maximum width for
  /// embedded images.
  ///
  /// Optionally specify the [emptyMessageText] for messages that contain no
  /// other content.
  ///
  /// Optionally specify the [transformConfiguration] to control all aspects
  /// of the transformation - in that case other parameters are ignored.
  Document transformToDocument({
    bool blockExternalImages = false,
    bool preferPlainText = false,
    bool enableDarkMode = false,
    int? maxImageWidth,
    String? emptyMessageText,
    TransformConfiguration? transformConfiguration,
  }) {
    transformConfiguration ??= TransformConfiguration.create(
      blockExternalImages: blockExternalImages,
      preferPlainText: preferPlainText,
      enableDarkMode: enableDarkMode,
      emptyMessageText: emptyMessageText,
      maxImageWidth: maxImageWidth,
    );
    final transformer = MimeMessageTransformer(transformConfiguration);
    return transformer.toDocument(this);
  }

  /// Transforms this message to HTML code.
  ///
  /// Set [blockExternalImages] to `true` in case external images
  /// should be blocked.
  ///
  /// Set [preferPlainText] to `true` to use plain text instead of the
  /// HTML text.
  ///
  /// Set [enableDarkMode] to `true` to enforce dark mode on devices with
  /// older browsers.
  ///
  /// Optionally specify the [maxImageWidth] to set the maximum width for
  /// embedded images.
  ///
  /// Optionally specify the [emptyMessageText] for messages that contain no
  /// other content.
  ///
  /// Optionally specify the [transformConfiguration] to control all aspects
  /// of the transformation - in that case other parameters are ignored.
  String transformToHtml({
    bool blockExternalImages = false,
    bool preferPlainText = false,
    bool enableDarkMode = false,
    int? maxImageWidth,
    String? emptyMessageText,
    TransformConfiguration? transformConfiguration,
  }) {
    final document = transformToDocument(
      blockExternalImages: blockExternalImages,
      preferPlainText: preferPlainText,
      enableDarkMode: enableDarkMode,
      maxImageWidth: maxImageWidth,
      emptyMessageText: emptyMessageText,
      transformConfiguration: transformConfiguration,
    );
    return document.outerHtml;
  }

  /// Transforms this message to the innter BODY HTML code.
  ///
  /// Set [blockExternalImages] to `true` in case external images should
  /// be blocked.
  ///
  /// Set [preferPlainText] to `true` to use plain text instead of the
  /// HTML text.
  ///
  /// Set [enableDarkMode] to `true` to enforce dark mode on devices with
  /// older browsers.
  ///
  /// Optionally specify the [maxImageWidth] to set the maximum width for
  /// embedded images.
  ///
  /// Optionally specify the [emptyMessageText] for messages that contain no
  /// other content.
  ///
  /// Optionally specify the [transformConfiguration] to control all aspects
  /// of the transformation - in that case other parameters are ignored.
  String transformToBodyInnerHtml({
    bool blockExternalImages = false,
    bool preferPlainText = false,
    bool enableDarkMode = false,
    int? maxImageWidth,
    String? emptyMessageText,
    TransformConfiguration? transformConfiguration,
  }) {
    final document = transformToDocument(
      blockExternalImages: blockExternalImages,
      preferPlainText: preferPlainText,
      enableDarkMode: enableDarkMode,
      maxImageWidth: maxImageWidth,
      emptyMessageText: emptyMessageText,
      transformConfiguration: transformConfiguration,
    );
    return document.body!.innerHtml;
  }

  /// Quotes the body of this message for editing HTML.
  ///
  /// Optionally specify the [quoteHeaderTemplate], defaults to
  /// `MailConventions.defaultReplyHeaderTemplate`, for forwarding you
  /// can use the `MailConventions.defaultForwardHeaderTemplate`.
  ///
  /// Set [blockExternalImages] to `true` in case external images
  /// should be blocked.
  ///
  /// Set [preferPlainText] to `true` to use plain text instead of the
  /// HTML text.
  ///
  /// Set [enableDarkMode] to `true` to enforce dark mode on devices
  /// with older browsers.
  ///
  /// Optionally specify the [maxImageWidth] to set the maximum width
  /// for embedded images.
  ///
  /// Optionally specify the [emptyMessageText] for messages that contain
  /// no other content.
  ///
  /// Optionally specify the [transformConfiguration] to control all aspects
  /// of the transformation - in that case other parameters are ignored.
  String quoteToHtml({
    String? quoteHeaderTemplate,
    bool preferPlainText = false,
    bool blockExternalImages = false,
    bool enableDarkMode = false,
    int? maxImageWidth,
    String? emptyMessageText,
    TransformConfiguration? transformConfiguration,
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
      preferPlainText: preferPlainText,
      enableDarkMode: enableDarkMode,
      maxImageWidth: maxImageWidth,
      emptyMessageText: emptyMessageText,
      transformConfiguration: transformConfiguration,
    );
    return '<p><br/></p><blockquote>$quoteHeader<br/>${document.body!.innerHtml}</blockquote>';
  }
}
