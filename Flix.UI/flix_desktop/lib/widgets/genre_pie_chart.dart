import 'dart:math';
import 'package:flix_desktop/models/genre_percentage.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';

class GenrePieChart extends StatelessWidget {
  const GenrePieChart({super.key, required this.genres});

  static const int _namedSlices = 6;

  static const List<Color> _palette = [
    Color(0xFFD9151C),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];

  final List<GenrePercentage> genres;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<_Slice> slices = _buildSlices();

    if (slices.isEmpty) {
      return Center(
        child: Text(
          "No movies to break down yet",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 52,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              painter: _PiePainter(
                slices: slices,
                borderColor: colors.surfaceContainerLowest,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 48, child: _buildLegend(context, slices)),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, List<_Slice> slices) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final _Slice slice in slices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: slice.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slice.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${formatPercentage(slice.percentage)}%",
                    style: TextStyle(
                      color: slice.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_Slice> _buildSlices() {
    final List<GenrePercentage> used = genres
        .where((genre) => (genre.percentage ?? 0) > 0)
        .toList();

    if (used.isEmpty) return List.empty();

    final List<_Slice> slices = [];

    for (int i = 0; i < min(_namedSlices, used.length); i++) {
      slices.add(_Slice(
        label: used[i].genre?.name ?? "Unknown",
        percentage: used[i].percentage ?? 0,
        color: _palette[i % _palette.length],
      ));
    }

    if (used.length > _namedSlices) {
      final double rest = used
          .skip(_namedSlices)
          .fold(0.0, (sum, genre) => sum + (genre.percentage ?? 0));

      slices.add(_Slice(
        label: "Other",
        percentage: rest,
        color: const Color(0xFF9CA3AF),
      ));
    }

    return slices;
  }
}

class _Slice {
  const _Slice({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final double percentage;
  final Color color;
}

class _PiePainter extends CustomPainter {
  const _PiePainter({required this.slices, required this.borderColor});

  final List<_Slice> slices;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double total =
        slices.fold(0.0, (sum, slice) => sum + slice.percentage);

    if (total <= 0) return;

    final double radius = min(size.width, size.height) / 2;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final Paint divider = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double start = -pi / 2;

    for (final _Slice slice in slices) {
      final double sweep = 2 * pi * slice.percentage / total;

      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.fill,
      );
      canvas.drawArc(rect, start, sweep, true, divider);

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.borderColor != borderColor;
  }
}
