import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    super.key,
    required this.text,
    this.collapsedLines = 4,
    this.style,
  });

  final String text;
  final int collapsedLines;
  final TextStyle? style;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const String _dots = "...";

  late final TapGestureRecognizer _toggleRecognizer;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _toggleRecognizer = TapGestureRecognizer()
      ..onTap = () => setState(() => _isExpanded = !_isExpanded);
  }

  @override
  void dispose() {
    _toggleRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final TextStyle style = DefaultTextStyle.of(
      context,
    ).style.merge(widget.style);

    final TextStyle dotsStyle = style.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(widget.text, style: style);
        }

        if (_isExpanded) {
          return _buildText(style, dotsStyle, widget.text);
        }

        final TextPainter dotsPainter = TextPainter(
          text: TextSpan(text: _dots, style: dotsStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();

        // Where the last visible line has to be cut so the dots still fit on it.
        final TextPosition end = painter.getPositionForOffset(
          Offset(painter.width - dotsPainter.width, painter.height),
        );
        final int cutoff = painter.getOffsetBefore(end.offset) ?? end.offset;

        return _buildText(
          style,
          dotsStyle,
          widget.text.substring(0, cutoff).trimRight(),
        );
      },
    );
  }

  Widget _buildText(TextStyle style, TextStyle dotsStyle, String text) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: _isExpanded ? "$text " : text),
          TextSpan(
            text: _dots,
            style: dotsStyle,
            recognizer: _toggleRecognizer,
          ),
        ],
      ),
    );
  }
}
