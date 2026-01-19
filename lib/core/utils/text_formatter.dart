import 'package:flutter/material.dart';

class TextFormatter {
  /// Formats text with **bold** markdown into TextSpans
  static List<InlineSpan> formatBoldText(String text, TextStyle? baseStyle) {
    final List<InlineSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');

    // Check if there are any bold patterns
    if (!boldPattern.hasMatch(text)) {
      // No bold text, return as is
      return [TextSpan(text: text, style: baseStyle)];
    }

    int lastMatchEnd = 0;

    for (final match in boldPattern.allMatches(text)) {
      // Add text before the bold part
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      // Add bold text (the content inside **)
      spans.add(TextSpan(
        text: match.group(1), // This gets the text between **
        style: baseStyle?.copyWith(fontWeight: FontWeight.bold) ??
            const TextStyle(fontWeight: FontWeight.bold),
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text after last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }

  /// Builds a RichText widget with bold formatting
  static Widget buildFormattedText(
      String text, {
        TextStyle? style,
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
      }) {
    return RichText(
      text: TextSpan(children: formatBoldText(text, style)),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
