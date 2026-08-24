import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/studio.dart';
import 'package:flix_mobile/screens/studio_profile.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsTab extends StatelessWidget {
  const DetailsTab({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Studio"),
        _buildStudios(context),
        const SizedBox(height: 20),
        _buildLabel(context, "Trailer"),
        _buildTrailer(context),
        const SizedBox(height: 20),
        _buildLabel(context, "Runtime"),
        Text(
          _durationText,
          style: TextStyle(color: colors.onSurface, fontSize: 14),
        ),
        const SizedBox(height: 20),
        _buildLabel(context, "Description"),
        Text(
          movie.description?.trim().isNotEmpty == true
              ? movie.description!.trim()
              : "No description available.",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String get _durationText {
    final int? minutes = movie.durationMinutes;
    if (minutes == null || minutes <= 0) return "Unknown";

    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;

    return hours == 0 ? "$rest mins" : "${hours}h ${rest}m ($minutes mins)";
  }

  Widget _buildLabel(BuildContext context, String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStudios(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<Studio> studios = (movie.studios ?? const [])
        .where((studio) => studio.id != null)
        .toList();

    if (studios.isEmpty) {
      return buildEmpty(context, "No studio listed for this movie.");
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final Studio studio in studios)
          InkWell(
            onTap: () => _openStudio(context, studio),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    studio.name ?? "-",
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right, size: 18, color: colors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _openStudio(BuildContext context, Studio studio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudioProfile(studioId: studio.id),
      ),
    );
  }

  Widget _buildTrailer(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Uri? trailer = httpUri(movie.trailerUrl);

    if (trailer == null) {
      return buildEmpty(context, "No trailer available.");
    }

    return InkWell(
      onTap: () => _openTrailer(context, trailer),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                movie.trailerUrl!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTrailer(BuildContext context, Uri trailer) async {
    bool opened = false;

    try {
      opened = await launchUrl(trailer, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (opened || !context.mounted) return;

    showSnack(context, "Could not open the trailer.");
  }
}
