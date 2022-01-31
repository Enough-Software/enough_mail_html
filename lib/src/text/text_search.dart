/// Iterates through texts
class TextSearchIterator {
  /// Create a new text search iterator
  TextSearchIterator(
    this.searchPattern,
    this.text, {
    this.endSearchPattern,
    this.endSearchPatternCanBeEndOfText = false,
  });

  int _searchIndex = 0;

  /// What to search for
  final String searchPattern;

  /// The text that should be searched in
  final String text;

  /// The optional end search text
  ///
  /// Compare [endSearchPatternCanBeEndOfText]
  final String? endSearchPattern;

  /// Defines if instead of the [endSearchPattern] also the end of the text
  /// is a valid stop.
  final bool endSearchPatternCanBeEndOfText;

  /// Retrieves the next match
  String? next() {
    if (_searchIndex == -1) {
      return null;
    }
    final nextIndex = text.indexOf(searchPattern, _searchIndex);
    if (nextIndex == -1) {
      _searchIndex = -1;
      return null;
    }
    final endSearchPattern = this.endSearchPattern;
    if (endSearchPattern != null) {
      final endIndex = text.indexOf(endSearchPattern, nextIndex + 1);
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

/// Like a [TextSearchIterator] with more options for ending a search.
class FlexibleEndTextSearchIterator {
  /// Creates a new flexible text search
  FlexibleEndTextSearchIterator(
    this.searchPattern,
    this.text, {
    this.endSearchPatterns,
    this.endSearchPatternCanBeEndOfText = false,
  });

  int _searchIndex = 0;

  /// What to search for
  final String searchPattern;

  /// The text that should be searched in
  final String text;

  /// The optional end search text
  ///
  /// Compare [endSearchPatternCanBeEndOfText]
  final List<String>? endSearchPatterns;

  /// Defines if instead of the [endSearchPatterns] also the end of the text
  /// is a valid stop.
  final bool endSearchPatternCanBeEndOfText;

  /// Retrieves the next matching text
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
