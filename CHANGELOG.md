## 2.0.0
- New `preferPlainText` option to use the mime message's plain text instead of the html part when available.
- Convert HTML line-breaks to plain text line-breaks when calling `HtmlToPlainTextConverter.convert(String html);` 
- New `enableDarkMode` option to improve dark mode display for older browser engines
- Ensure compatibility with enough_mail 2.0.0
- Improve documentation


## 1.3.0
- Do not include the `enough_mail` package automatically to keep documentation simpler

## 1.2.0
- Add `HtmlToPlainTextConverter` with HTML to plain text conversion

## 1.1.0
- Fix link detection and replace in plain text messages
- Use fetchId rather than the content-ID for inline images. Links starting with `fetch://` will be generated.

## 1.0.0
- `enough_mail_html` is now [null safe](https://dart.dev/null-safety/tour) #6
- use URL safe links when linking an embedded image with a `content-ID`
- limit image width in `<img>` elements when `maxImageWidth` is specified


## 0.4.0
- override `<meta charset="...">` elements to always be UTF-8
- add `quoteToHtml(...)` extension method to `MimeMessage`
- recognize and handle any links in plain text messages

## 0.3.0
- allow to specify the `maxImageWidth` when generating the HTML, this preserves memory
- surround inline images with cid:// links - #5
- remove common invalid characters at end of links

## 0.2.1
- Always setting the `Content-Type` meta attribute to use 'utf-8' encoding
- Add inline images even when they are not referenced

## 0.2.0

- Added plain text transformations:
  - Convert line breaks into `<br/>` tags
  - Convert https lins into `<a>` tags

## 0.1.1

- Fixes transformation of plain text messages

## 0.1.0

- Initial version
