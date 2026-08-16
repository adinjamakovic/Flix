import 'package:flix_mobile/models/review_count.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';

class RatingCountChart extends StatelessWidget {
  const RatingCountChart({
    super.key,
    required this.counts,
    this.title = "RATINGS",
    this.barHeight = 56,
  });

  final ReviewCount counts;
  final String title;

  final double barHeight;

  static const List<double> _steps = [
    0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0,
  ];

  static const double _labelHeight = 14;
  static const double _barGap = 1.5;
  static const double _starSize = 14;

  static const double _minBarHeight = 2;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (counts.maxCount == 0)
            buildEmpty(context, "No ratings yet")
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: _labelHeight),
                  child: Icon(
                    Icons.star,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildHistogram(context)),
                const SizedBox(width: 12),
                _buildAverage(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHistogram(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int tallest = counts.maxCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final double step in _steps)
                Expanded(child: _buildBar(context, step, tallest)),
            ],
          ),
        ),
        Container(height: 1, color: colors.outline),
        SizedBox(
          height: _labelHeight,
          child: Row(
            children: [
              for (final double step in _steps)
                Expanded(child: _buildLabel(context, step)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(BuildContext context, double step, int tallest) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final int count = counts.countFor(step);
    final double filled = tallest == 0 ? 0 : (count / tallest) * barHeight;

    return Tooltip(
      message: "$count ${count == 1 ? "rating" : "ratings"} at $step",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _barGap),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: filled < _minBarHeight ? _minBarHeight : filled,
            decoration: BoxDecoration(
              color: count == 0
                  ? colors.outlineVariant
                  : colors.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, double step) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String label = step == step.roundToDouble()
        ? step.toStringAsFixed(0)
        : step.toString();

    return Center(
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAverage(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double average = counts.averageRating ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: _labelHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            average.toStringAsFixed(1),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(height: _labelHeight, child: _buildStars(context, average)),
        ],
      ),
    );
  }

  Widget _buildStars(BuildContext context, double average) {
    final int halfStars = (average.clamp(0, 5) * 2).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 0; index < 5; index++)
          _buildStar(context, (halfStars - index * 2).clamp(0, 2)),
      ],
    );
  }

  Widget _buildStar(BuildContext context, int halves) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Icon(
      halves == 2
          ? Icons.star
          : halves == 1
          ? Icons.star_half
          : Icons.star_border,
      size: _starSize,
      color: halves == 0 ? colors.outlineVariant : colors.onSurfaceVariant,
    );
  }
}
