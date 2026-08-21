import 'package:flix_mobile/models/genre.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';

class GenreTab extends StatelessWidget {
  const GenreTab({super.key, required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (genres.isEmpty) {
      return buildEmpty(context, "No genres listed for this movie.");
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final Genre genre in genres)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              genre.name ?? "-",
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
