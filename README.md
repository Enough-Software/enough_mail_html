Generate html code from any email mime message for displaying it.
 
## Usage
The `enough_mail_html` package defines the `decodeTextHtmlForDisplay()` extension method on `MimeMessage`.

This method will always generate HTML, specifically also for plain text or empty messages.
You can define your custom processors
* for converting a plain text message into HTML,
* for adapting the HTML message,
* for handling inline attachments.

A simple usage example:

```dart
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

String generateHtml(MimeMessage mimeMessage) {
  return mimeMessage.transformToHtml(
        blockExternalImages: false, emptyMessageText: 'Nothing here, move on!');
}
```

More examples:
```dart
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:html/dom.dart';

String simpleTransformExample(MimeMessage mimeMessage) {
  return mimeMessage.transformToHtml();
}

String configureImageBlockingOrEmptyMessage(MimeMessage mimeMessage) {
  return mimeMessage.transformToHtml(
      blockExternalImages: true, emptyMessageText: 'Nothing here, move on!');
}

String playYourself(MimeMessage mimeMessage) {
  final cfg = TransformConfiguration.create(
      blockExternalImages: true,
      emptyMessageText: 'Nothing here, move on!',
      customDomTransformers: [StyleTextDomTransformer()],
      customValues: {'textStyle': 'font-size:10px;font-family:verdana;'});
  return mimeMessage.transformToHtml(transformConfiguration: cfg);
}

class StyleTextDomTransformer extends DomTransformer {
  @override
  void process(Document document, MimeMessage message,
      TransformConfiguration configuration) {
    final paragraphs = document.getElementsByTagName('p');
    for (final paragraph in paragraphs) {
      paragraph.attributes['style'] = configuration.customValues['textStyle'];
    }
  }
}

```

## Installation
Add this dependency your pubspec.yaml file:

```
dependencies:
  enough_mail: ^0.1.0
```
The latest version or `enough_mail_html` is [![enough_mail_html version](https://img.shields.io/pub/v/enough_mail_html.svg)](https://pub.dartlang.org/packages/enough_mail_html).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/enough-software/enough_mail_html/issues

## License

Licensed under the commercial friendly [Mozilla Public License 2.0](LICENSE).