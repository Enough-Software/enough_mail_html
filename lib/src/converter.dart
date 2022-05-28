/// Converts HTML text into a plain text message.
class HtmlToPlainTextConverter {
  // disallow instantiation:
  HtmlToPlainTextConverter._();

  static final _htmlEntityRegex = RegExp(r'&(#?)([a-zA-Z0-9]+?);');
  static final _htmlTagRegex =
      RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

  static final _lineBreakOrWhiteSpaceRegex =
      RegExp(r'([\r\n]|[\n]|s)*', multiLine: true, caseSensitive: true);

  /// Converts the given [htmlText] into plain text.
  ///
  /// - It keeps code untouched in the `<pre>` elements
  /// - Blockquotes are transformed into lines starting with `>`
  /// - HTML entities are transformed to their plain text representation
  static String convert(final String htmlText) {
    final matches = _htmlTagRegex.allMatches(htmlText).toList();
    final plainTextBuffer = StringBuffer();
    var lastMatchIndex = 0;
    var blockquoteCounter = 0;
    var orderedListItemIndex = 0;
    var isInOrderedList = false;
    var isInUnorderedList = false;
    for (var i = 0; i < matches.length; i++) {
      var match = matches[i];
      if (match.start > lastMatchIndex) {
        final textBetweenMatches =
            htmlText.substring(lastMatchIndex, match.start);
        writeConvertHtmlEntities(textBetweenMatches, plainTextBuffer);
      }
      final tag = match.group(0)!.toLowerCase();
      if (tag.startsWith('<pre')) {
        final preContentStart = match.end;
        for (var j = i + 1; j < matches.length; j++) {
          final inPreMatch = matches[j];
          final inPreTag = inPreMatch.group(0)!.toLowerCase();
          if (inPreTag.startsWith('</pre')) {
            i = j;
            plainTextBuffer
                .write(htmlText.substring(preContentStart, inPreMatch.start));
            match = inPreMatch;
            break;
          }
        }
      } else if (tag.startsWith('<blockquote')) {
        plainTextBuffer.write('>');
        blockquoteCounter++;
      } else if (tag.startsWith('</blockquote')) {
        blockquoteCounter--;
      } else if (tag.startsWith('<p') || tag.startsWith('<br')) {
        plainTextBuffer.write('\n');
        for (var q = 0; q < blockquoteCounter; q++) {
          plainTextBuffer.write('>');
        }
      } else if (tag.startsWith('<ul')) {
        isInUnorderedList = true;
      } else if (isInUnorderedList && tag.startsWith('</ul')) {
        isInUnorderedList = false;
        plainTextBuffer.write('\n');
      } else if (tag.startsWith('<ol')) {
        isInOrderedList = true;
        orderedListItemIndex = 0;
      } else if (isInOrderedList && tag.startsWith('</ol')) {
        isInOrderedList = false;
        plainTextBuffer.write('\n');
      } else if (tag.startsWith('<li')) {
        plainTextBuffer.write('\n');
        if (isInUnorderedList) {
          plainTextBuffer.write(' * ');
        } else {
          orderedListItemIndex++;
          plainTextBuffer
            ..write(' ')
            ..write(orderedListItemIndex)
            ..write('. ');
        }
      }
      lastMatchIndex = match.end;
    }
    if (lastMatchIndex < htmlText.length) {
      writeConvertHtmlEntities(
          htmlText.substring(lastMatchIndex), plainTextBuffer);
    }
    // remove line-breaks and whitespace at start:
    final plainText = plainTextBuffer
        .toString()
        .replaceFirst(_lineBreakOrWhiteSpaceRegex, '');
    return plainText;
  }

  /// Converts the HTML entities such as `&amp;` in the specified the [input].
  static String convertHtmlEntities(String input) {
    final buffer = StringBuffer();
    writeConvertHtmlEntities(input, buffer);
    return buffer.toString();
  }

  /// Writes the HTML entities such as `&amp;`
  /// from the [input] into the [target] StringBuffer.
  static void writeConvertHtmlEntities(String input, StringBuffer target) {
    final matches = _htmlEntityRegex.allMatches(input);
    var lastStartIndex = 0;
    for (final match in matches) {
      if (match.start > lastStartIndex) {
        target.write(input.substring(lastStartIndex, match.start));
      }
      final entity = match.group(0)!;
      final replacement = _characters[entity];
      if (replacement != null) {
        target.write(replacement);
      } else {
        int? charCode;
        if (entity.startsWith('&#x')) {
          // this is a hexadecimal number:
          final hexText = entity.substring('&#x'.length, entity.length - 1);
          charCode = int.tryParse(hexText, radix: 16);
        } else if (entity.startsWith('&#')) {
          final text = entity.substring('&#'.length, entity.length - 1);
          charCode = int.tryParse(text);
        }
        if (charCode != null) {
          final charText = String.fromCharCode(charCode);
          target.write(charText);
        } else {
          print('Warning: unable to decode HTML entity "$entity"');
          target.write(entity);
        }
      }
      lastStartIndex = match.end;
    }
    if (lastStartIndex < input.length) {
      target.write(input.substring(lastStartIndex));
    }
  }

  //cSpell:disable
  /// A map of all HTML 4.01 character entities
  /// and their corresponding characters.
  /// Taken from https://github.com/james-alex/html_character_entities/blob/master/lib/src/html_character_entities.dart
  static const Map<String, String> _characters = <String, String>{
    // double quote
    '&quot;': '"',
    // ampersand
    '&amp;': '&',
    // apostrophe (single quote)
    '&apos;': '\'',
    // less-than
    '&lt;': '<',
    // greater-than
    '&gt;': '>',
    // non-breaking space
    '&nbsp;': ' ',
    // inverted exclamation mark
    '&iexcl;': '¡',
    // cent sign
    '&cent;': '¢',
    // pound sign
    '&pound;': '£',
    // currency sign
    '&curren;': '¤',
    // yen sign (yuan sign)
    '&yen;': '¥',
    // broken bar (broken vertical bar)
    '&brvbar;': '¦',
    // section sign
    '&sect;': '§',
    // diaeresis (spacing diaeresis)
    '&uml;': '¨',
    // copyright symbol
    '&copy;': '©',
    // feminine ordinal indicator
    '&ordf;': 'ª',
    // left-pointing double angle quotation mark (left pointing guillemet)
    '&laquo;': '«',
    // not sign
    '&not;': '¬',
    // soft hyphen (discretionary hyphen)
    '&shy;': '',
    // registered sign (registered trademark symbol)
    '&reg;': '®',
    // macron (spacing macron, overline, APL overbar)
    '&macr;': '¯',
    // degree symbol
    '&deg;': '°',
    // plus-minus sign (plus-or-minus sign)
    '&plusmn;': '±',
    // superscript two (superscript digit two, squared)
    '&sup2;': '²',
    // superscript three (superscript digit three, cubed)
    '&sup3;': '³',
    // acute accent (spacing acute)
    '&acute;': '´',
    // micro sign
    '&micro;': 'µ',
    // pilcrow sign (paragraph sign)
    '&para;': '¶',
    // middle dot (Georgian comma, Greek middle dot)
    '&middot;': '·',
    // cedilla (spacing cedilla)
    '&cedil;': '¸',
    // superscript one (superscript digit one)
    '&sup1;': '¹',
    // masculine ordinal indicator
    '&ordm;': 'º',
    // right-pointing double angle quotation mark (right pointing guillemet)
    '&raquo;': '»',
    // vulgar fraction one quarter (fraction one quarter)
    '&frac14;': '¼',
    // vulgar fraction one half (fraction one half)
    '&frac12;': '½',
    // vulgar fraction three quarters (fraction three quarters)
    '&frac34;': '¾',
    // inverted question mark (turned question mark)
    '&iquest;': '¿',
    // Latin capital letter A with grave accent (Latin capital letter A grave)
    '&Agrave;': 'À',
    // Latin capital letter A with acute accent
    '&Aacute;': 'Á',
    // Latin capital letter A with circumflex
    '&Acirc;': 'Â',
    // Latin capital letter A with tilde
    '&Atilde;': 'Ã',
    // Latin capital letter A with diaeresis
    '&Auml;': 'Ä',
    // Latin capital letter A with ring above (Latin capital letter A ring)
    '&Aring;': 'Å',
    // Latin capital letter AE (Latin capital ligature AE)
    '&AElig;': 'Æ',
    // Latin capital letter C with cedilla
    '&Ccedil;': 'Ç',
    // Latin capital letter E with grave accent
    '&Egrave;': 'È',
    // Latin capital letter E with acute accent
    '&Eacute;': 'É',
    // Latin capital letter E with circumflex
    '&Ecirc;': 'Ê',
    // Latin capital letter E with diaeresis
    '&Euml;': 'Ë',
    // Latin capital letter I with grave accent
    '&Igrave;': 'Ì',
    // Latin capital letter I with acute accent
    '&Iacute;': 'Í',
    // Latin capital letter I with circumflex
    '&Icirc;': 'Î',
    // Latin capital letter I with diaeresis
    '&Iuml;': 'Ï',
    // Latin capital letter Eth
    '&ETH;': 'Ð',
    // Latin capital letter N with tilde
    '&Ntilde;': 'Ñ',
    // Latin capital letter O with grave accent
    '&Ograve;': 'Ò',
    // Latin capital letter O with acute accent
    '&Oacute;': 'Ó',
    // Latin capital letter O with circumflex
    '&Ocirc;': 'Ô',
    // Latin capital letter O with tilde
    '&Otilde;': 'Õ',
    // Latin capital letter O with diaeresis
    '&Ouml;': 'Ö',
    // multiplication sign
    '&times;': '×',
    // Latin capital letter O with stroke (Latin capital letter O slash)
    '&Oslash;': 'Ø',
    // Latin capital letter U with grave accent
    '&Ugrave;': 'Ù',
    // Latin capital letter U with acute accent
    '&Uacute;': 'Ú',
    // Latin capital letter U with circumflex
    '&Ucirc;': 'Û',
    // Latin capital letter U with diaeresis
    '&Uuml;': 'Ü',
    // Latin capital letter Y with acute accent
    '&Yacute;': 'Ý',
    // Latin capital letter THORN
    '&THORN;': 'Þ',
    // Latin small letter sharp s (ess-zed); see German Eszett
    '&szlig;': 'ß',
    // Latin small letter a with grave accent
    '&agrave;': 'à',
    // Latin small letter a with acute accent
    '&aacute;': 'á',
    // Latin small letter a with circumflex
    '&acirc;': 'â',
    // Latin small letter a with tilde
    '&atilde;': 'ã',
    // Latin small letter a with diaeresis
    '&auml;': 'ä',
    // Latin small letter a with ring above
    '&aring;': 'å',
    // Latin small letter ae (Latin small ligature ae)
    '&aelig;': 'æ',
    // Latin small letter c with cedilla
    '&ccedil;': 'ç',
    // Latin small letter e with grave accent
    '&egrave;': 'è',
    // Latin small letter e with acute accent
    '&eacute;': 'é',
    // Latin small letter e with circumflex
    '&ecirc;': 'ê',
    // Latin small letter e with diaeresis
    '&euml;': 'ë',
    // Latin small letter i with grave accent
    '&igrave;': 'ì',
    // Latin small letter i with acute accent
    '&iacute;': 'í',
    // Latin small letter i with circumflex
    '&icirc;': 'î',
    // Latin small letter i with diaeresis
    '&iuml;': 'ï',
    // Latin small letter eth
    '&eth;': 'ð',
    // Latin small letter n with tilde
    '&ntilde;': 'ñ',
    // Latin small letter o with grave accent
    '&ograve;': 'ò',
    // Latin small letter o with acute accent
    '&oacute;': 'ó',
    // Latin small letter o with circumflex
    '&ocirc;': 'ô',
    // Latin small letter o with tilde
    '&otilde;': 'õ',
    // Latin small letter o with diaeresis
    '&ouml;': 'ö',
    // division sign (obelus)
    '&divide;': '÷',
    // Latin small letter o with stroke (Latin small letter o slash)
    '&oslash;': 'ø',
    // Latin small letter u with grave accent
    '&ugrave;': 'ù',
    // Latin small letter u with acute accent
    '&uacute;': 'ú',
    // Latin small letter u with circumflex
    '&ucirc;': 'û',
    // Latin small letter u with diaeresis
    '&uuml;': 'ü',
    // Latin small letter y with acute accent
    '&yacute;': 'ý',
    // Latin small letter thorn
    '&thorn;': 'þ',
    // Latin small letter y with diaeresis
    '&yuml;': 'ÿ',
    // Latin capital ligature oe
    '&OElig;': 'Œ',
    // Latin small ligature oe
    '&oelig;': 'œ',
    // Latin capital letter s with caron
    '&Scaron;': 'Š',
    // Latin small letter s with caron
    '&scaron;': 'š',
    // Latin capital letter y with diaeresis
    '&Yuml;': 'Ÿ',
    // Latin small letter f with hook (function, florin)
    '&fnof;': 'ƒ',
    // modifier letter circumflex accent
    '&circ;': 'ˆ',
    // small tilde
    '&tilde;': '˜',
    // Greek capital letter Alpha
    '&Alpha;': 'Α',
    // Greek capital letter Beta
    '&Beta;': 'Β',
    // Greek capital letter Gamma
    '&Gamma;': 'Γ',
    // Greek capital letter Delta
    '&Delta;': 'Δ',
    // Greek capital letter Epsilon
    '&Epsilon;': 'Ε',
    // Greek capital letter Zeta
    '&Zeta;': 'Ζ',
    // Greek capital letter Eta
    '&Eta;': 'Η',
    // Greek capital letter Theta
    '&Theta;': 'Θ',
    // Greek capital letter Iota
    '&Iota;': 'Ι',
    // Greek capital letter Kappa
    '&Kappa;': 'Κ',
    // Greek capital letter Lambda
    '&Lambda;': 'Λ',
    // Greek capital letter Mu
    '&Mu;': 'Μ',
    // Greek capital letter Nu
    '&Nu;': 'Ν',
    // Greek capital letter Xi
    '&Xi;': 'Ξ',
    // Greek capital letter Omicron
    '&Omicron;': 'Ο',
    // Greek capital letter Pi
    '&Pi;': 'Π',
    // Greek capital letter Rho
    '&Rho;': 'Ρ',
    // Greek capital letter Sigma
    '&Sigma;': 'Σ',
    // Greek capital letter Tau
    '&Tau;': 'Τ',
    // Greek capital letter Upsilon
    '&Upsilon;': 'Υ',
    // Greek capital letter Phi
    '&Phi;': 'Φ',
    // Greek capital letter Chi
    '&Chi;': 'Χ',
    // Greek capital letter Psi
    '&Psi;': 'Ψ',
    // Greek capital letter Omega
    '&Omega;': 'Ω',
    // Greek small letter alpha
    '&alpha;': 'α',
    // Greek small letter beta
    '&beta;': 'β',
    // Greek small letter gamma
    '&gamma;': 'γ',
    // Greek small letter delta
    '&delta;': 'δ',
    // Greek small letter epsilon
    '&epsilon;': 'ε',
    // Greek small letter zeta
    '&zeta;': 'ζ',
    // Greek small letter eta
    '&eta;': 'η',
    // Greek small letter theta
    '&theta;': 'θ',
    // Greek small letter iota
    '&iota;': 'ι',
    // Greek small letter kappa
    '&kappa;': 'κ',
    // Greek small letter lambda
    '&lambda;': 'λ',
    // Greek small letter mu
    '&mu;': 'μ',
    // Greek small letter nu
    '&nu;': 'ν',
    // Greek small letter xi
    '&xi;': 'ξ',
    // Greek small letter omicron
    '&omicron;': 'ο',
    // Greek small letter pi
    '&pi;': 'π',
    // Greek small letter rho
    '&rho;': 'ρ',
    // Greek small letter final sigma
    '&sigmaf;': 'ς',
    // Greek small letter sigma
    '&sigma;': 'σ',
    // Greek small letter tau
    '&tau;': 'τ',
    // Greek small letter upsilon
    '&upsilon;': 'υ',
    // Greek small letter phi
    '&phi;': 'φ',
    // Greek small letter chi
    '&chi;': 'χ',
    // Greek small letter psi
    '&psi;': 'ψ',
    // Greek small letter omega
    '&omega;': 'ω',
    // Greek theta symbol
    '&thetasym;': 'ϑ',
    // Greek upsilon with hook symbol
    '&upsih;': 'ϒ',
    // Greek phi symbol
    '&straightphi;': 'ϕ',
    // Greek pi symbol
    '&piv;': 'ϖ',
    '&varpi;': 'ϖ',
    // en space
    '&ensp;': ' ',
    // em space
    '&emsp;': ' ',
    // thin space
    '&thinsp;': ' ',
    // zero-width non-joiner
    '&zwnj;': '',
    // zero-width joiner
    '&zwj;': '',
    // left-to-right mark
    '&lrm;': '',
    // right-to-left mark
    '&rlm;': '',
    // en dash
    '&ndash;': '–',
    // em dash
    '&mdash;': '—',
    // left single quotation mark
    '&lsquo;': '‘',
    // right single quotation mark
    '&rsquo;': '’',
    // single low-9 quotation mark
    '&sbquo;': '‚',
    // left double quotation mark
    '&ldquo;': '“',
    // right double quotation mark
    '&rdquo;': '”',
    // double low-9 quotation mark
    '&bdquo;': '„',
    // dagger, obelisk
    '&dagger;': '†',
    // double dagger (double obelisk)
    '&Dagger;': '‡',
    // bullet (black small circle)
    '&bull;': '•',
    // horizontal ellipsis (three dot leader)
    '&hellip;': '…',
    // per mille sign
    '&permil;': '‰',
    // prime (minutes, feet)
    '&prime;': '′',
    // double prime (seconds, inches)
    '&Prime;': '″',
    // single left-pointing angle quotation mark
    '&lsaquo;': '‹',
    // single right-pointing angle quotation mark
    '&rsaquo;': '›',
    // overline (spacing overscore)
    '&oline;': '‾',
    // fraction slash (solidus)
    '&frasl;': '⁄',
    // euro sign
    '&euro;': '€',
    // black-letter capital I (imaginary part)
    '&image;': 'ℑ',
    // script capital P (power set, Weierstrass p)
    '&weierp;': '℘',
    // black-letter capital R (real part symbol)
    '&real;': 'ℜ',
    // trademark symbol
    '&trade;': '™',
    // alef symbol (first transfinite cardinal)
    '&alefsym;': 'ℵ',
    // leftwards arrow
    '&larr;': '←',
    // upwards arrow
    '&uarr;': '↑',
    // rightwards arrow
    '&rarr;': '→',
    // downwards arrow
    '&darr;': '↓',
    // left right arrow
    '&harr;': '↔',
    // downwards arrow with corner leftwards (carriage return)
    '&crarr;': '↵',
    // leftwards double arrow
    '&lArr;': '⇐',
    // upwards double arrow
    '&uArr;': '⇑',
    // rightwards double arrow
    '&rArr;': '⇒',
    // downwards double arrow
    '&dArr;': '⇓',
    // left right double arrow
    '&hArr;': '⇔',
    // for all
    '&forall;': '∀',
    // partial differential
    '&part;': '∂',
    // there exists
    '&exist;': '∃',
    // empty set (null set)
    '&empty;': '∅',
    // del or nabla (vector differential operator)
    '&nabla;': '∇',
    // element of
    '&isin;': '∈',
    // not an element of
    '&notin;': '∉',
    // contains as member
    '&ni;': '∋',
    // n-ary product (product sign)
    '&prod;': '∏',
    // n-ary summation
    '&sum;': '∑',
    // minus sign
    '&minus;': '−',
    // asterisk operator
    '&lowast;': '∗',
    // square root (radical sign)
    '&radic;': '√',
    // proportional to
    '&prop;': '∝',
    // infinity
    '&infin;': '∞',
    // angle
    '&ang;': '∠',
    // logical and (wedge)
    '&and;': '∧',
    // logical or (vee)
    '&or;': '∨',
    // intersection (cap)
    '&cap;': '∩',
    // union (cup)
    '&cup;': '∪',
    // integral
    '&int;': '∫',
    // therefore sign
    '&there4;': '∴',
    // tilde operator (varies with, similar to)
    '&sim;': '∼',
    // congruent to
    '&cong;': '≅',
    // almost equal to (asymptotic to)
    '&asymp;': '≈',
    // not equal to
    '&ne;': '≠',
    // identical to; sometimes used for 'equivalent to'
    '&equiv;': '≡',
    // less-than or equal to
    '&le;': '≤',
    // greater-than or equal to
    '&ge;': '≥',
    // subset of
    '&sub;': '⊂',
    // superset of
    '&sup;': '⊃',
    // not a subset of
    '&nsub;': '⊄',
    // subset of or equal to
    '&sube;': '⊆',
    // superset of or equal to
    '&supe;': '⊇',
    // circled plus (direct sum)
    '&oplus;': '⊕',
    // circled times (vector product)
    '&otimes;': '⊗',
    // up tack (orthogonal to, perpendicular)
    '&perp;': '⊥',
    // dot operator
    '&sdot;': '⋅',
    // vertical ellipsis
    '&vellip;': '⋮',
    // left ceiling (APL upstile)
    '&lceil;': '⌈',
    // right ceiling
    '&rceil;': '⌉',
    // left floor (APL downstile)
    '&lfloor;': '⌊',
    // right floor
    '&rfloor;': '⌋',
    // left-pointing angle bracket (bra)
    '&lang;': '〈',
    // right-pointing angle bracket (ket)
    '&rang;': '〉',
    // lozenge
    '&loz;': '◊',
    // black spade suit
    '&spades;': '♠',
    // black club suit (shamrock)
    '&clubs;': '♣',
    // black heart suit (valentine)
    '&hearts;': '♥',
    // black diamond suit
    '&diams;': '♦',
  };
}
