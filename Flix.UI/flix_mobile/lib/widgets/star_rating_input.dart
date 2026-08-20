import 'package:flutter/material.dart';

/// The half-star rating row, shared by the actions sheet and the log form so a
/// rating is given the same way wherever it is given.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 34,
    this.gap = 9,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final double size;
  final double gap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => _buildStar(context, index + 1)),
    );
  }

  Widget _buildStar(BuildContext context, int position) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double fill = (rating - position + 1).clamp(0, 1);
    final IconData icon = fill == 0
        ? Icons.star_border
        : (fill < 1 ? Icons.star_half : Icons.star);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // The left half of a star sets the half rating, the right half the whole
      // one; tapping the current rating again clears it.
      onTapUp: enabled
          ? (details) {
              final double value = details.localPosition.dx < size / 2 + gap
                  ? position - 0.5
                  : position.toDouble();

              onChanged(rating == value ? 0 : value);
            }
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Icon(
          icon,
          size: size,
          color: fill == 0 ? colors.onSurface : colors.primary,
        ),
      ),
    );
  }
}
