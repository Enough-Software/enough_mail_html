import 'package:enough_mail/mime_message.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

class ConvertTagsTextProcessor implements TextTransformer {
  const ConvertTagsTextProcessor();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    return text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  }
}

class MergeAttachedImageTextProcessor extends TextTransformer {
  const MergeAttachedImageTextProcessor();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    final search = TextSearchIterator('[cid:', text, endSearchPattern: ']');
    String nextImageDefinition;
    while ((nextImageDefinition = search.next()) != null) {
      final cid = nextImageDefinition.substring(
          '[cid:'.length, nextImageDefinition.length - 2);
    }
  }
}

class TextSearchIterator {
  int _searchIndex = 0;
  final String searchPattern;
  final String text;
  final String endSearchPattern;

  TextSearchIterator(this.searchPattern, this.text, {this.endSearchPattern});

  String next() {
    if (_searchIndex == -1) {
      return null;
    }
    final nextIndex = text.indexOf(searchPattern, _searchIndex);
    if (nextIndex == -1) {
      _searchIndex = -1;
      return null;
    }
    if (endSearchPattern != null) {
      final endIndex = text.indexOf(endSearchPattern, nextIndex + 1);
      if (endIndex == -1) {
        _searchIndex = -1;
        return null;
      }
      _searchIndex = endIndex + 1;
      return text.substring(nextIndex, endIndex);
    } else {
      _searchIndex = nextIndex + searchPattern.length;
      return text.substring(nextIndex);
    }
  }
}
