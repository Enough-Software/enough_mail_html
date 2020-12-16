import 'package:enough_mail_html/src/text/linebreak_text_transformer.dart';
import 'package:test/test.dart';

void main() {
  group('Test linebreaks', () {
    test('linebreaks', () {
      final input = 'hello\r\nworld.\n';
      final transformer = LineBreakTextTransformer();
      expect(transformer.transform(input, null, null), 'hello<br/>world.<br/>');
    });
  });
}
