class TextSearchIterator {
  int _searchIndex = 0;
  final String searchPattern;
  final String text;
  final String? endSearchPattern;
  final bool endSearchPatternCanBeEndOfText;

  TextSearchIterator(this.searchPattern, this.text,
      {this.endSearchPattern, this.endSearchPatternCanBeEndOfText = false});

  String? next() {
    if (_searchIndex == -1) {
      return null;
    }
    final nextIndex = text.indexOf(searchPattern, _searchIndex);
    if (nextIndex == -1) {
      _searchIndex = -1;
      return null;
    }
    if (endSearchPattern != null) {
      final endIndex = text.indexOf(endSearchPattern!, nextIndex + 1);
      if (endIndex == -1) {
        _searchIndex = -1;
        if (endSearchPatternCanBeEndOfText) {
          return text.substring(nextIndex);
        }
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

class FlexibleEndTextSearchIterator {
  int _searchIndex = 0;
  final String searchPattern;
  final String text;
  final List<String>? endSearchPatterns;
  final bool endSearchPatternCanBeEndOfText;

  FlexibleEndTextSearchIterator(this.searchPattern, this.text,
      {this.endSearchPatterns, this.endSearchPatternCanBeEndOfText = false});

  String? next() {
    if (_searchIndex == -1) {
      return null;
    }
    final nextIndex = text.indexOf(searchPattern, _searchIndex);
    if (nextIndex == -1) {
      _searchIndex = -1;
      return null;
    }
    if (endSearchPatterns != null) {
      var endIndex = -1;
      for (final endPattern in endSearchPatterns!) {
        final end = text.indexOf(endPattern, nextIndex + 1);
        if (endIndex == -1) {
          endIndex = end;
        } else if (end != -1 && end < endIndex) {
          endIndex = end;
        }
      }
      if (endIndex == -1) {
        _searchIndex = -1;
        if (endSearchPatternCanBeEndOfText) {
          return text.substring(nextIndex);
        }
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
