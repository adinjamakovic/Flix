import 'package:flix_desktop/enums/movie_request_status.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/movie_request.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';

class SubmissionCard extends StatelessWidget {
  const SubmissionCard({
    super.key,
    required this.request,
    required this.onReview,
    required this.onOpenMovie,
  });

  static const double _posterWidth = 92;
  static const double _posterHeight = 132;

  final MovieRequest request;
  final VoidCallback onReview;
  final VoidCallback onOpenMovie;

  Movie? get _movie => request.movie;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPoster(context),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHeading(context)),
                    const SizedBox(width: 24),
                    SubmissionStatusChip(
                      status: request.status ?? MovieRequestStatus.pending,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _movie?.description?.trim().isNotEmpty == true
                      ? _movie!.description!.trim()
                      : "The requester wrote no description.",
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                _buildGaps(context),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: request.isPending
                      ? ElevatedButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.fact_check_outlined, size: 18),
                          label: const Text("Review submission"),
                        )
                      : OutlinedButton.icon(
                          onPressed: onOpenMovie,
                          icon: const Icon(Icons.movie_outlined, size: 18),
                          label: const Text("Open movie"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onSurface,
                            side: BorderSide(color: colors.outline),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Uri? uri = Uri.tryParse(_movie?.poster ?? "");
    final bool isNetworkImage =
        uri != null && (uri.scheme == "http" || uri.scheme == "https");

    final Widget placeholder = Icon(
      Icons.movie_outlined,
      size: 34,
      color: colors.onSurfaceVariant,
    );

    return Container(
      width: _posterWidth,
      height: _posterHeight,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetworkImage
          ? Image.network(
              uri.toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            )
          : placeholder,
    );
  }

  Widget _buildHeading(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final TextStyle byline = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 13.5,
    );

    final int? year = _movie?.releaseDate?.year;
    final String title = _movie?.title ?? "Untitled";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          year == null ? title : "$title ($year)",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: byline,
            children: [
              const TextSpan(text: "Requested by "),
              TextSpan(
                text: request.requestedByUser?.username ?? "-",
                style: byline.copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: " on ${formatDate(request.createdAt)}"),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Directed by ${_movie?.directorName ?? "-"}  ·  "
          "${_movie?.genreNames ?? "No genre"}",
          overflow: TextOverflow.ellipsis,
          style: byline,
        ),
      ],
    );
  }

  // A submission is only ever partially filled in, so what is still missing is
  // spelled out here rather than left for the admin to find in the form.
  Widget _buildGaps(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<String> gaps = [
      if (_movie?.poster == null) "No poster",
      if (_movie?.releaseDate == null) "No release date",
      if (_movie?.director == null) "No director",
      if (_movie?.genres?.isEmpty ?? true) "No genre",
      if (_movie?.description?.trim().isEmpty ?? true) "No description",
    ];

    if (gaps.isEmpty) {
      return Text(
        "Nothing obvious is missing.",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: gaps
          .map(
            (gap) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                gap,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class SubmissionStatusChip extends StatelessWidget {
  const SubmissionStatusChip({super.key, required this.status});

  // Same green the mobile client uses for a won clash - the palette carries
  // none of its own.
  static const Color _approvedColor = Color(0xFF22C55E);

  final MovieRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color color = switch (status) {
      MovieRequestStatus.pending => colors.primary,
      MovieRequestStatus.approved => _approvedColor,
      MovieRequestStatus.rejected => colors.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getMovieRequestStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
