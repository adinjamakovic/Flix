import 'package:flix_mobile/layouts/profile_screen.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';

// Fed the review carried by the feed it was tapped in, so what it can show
// depends on that search having been sent with includeUser/includeMovie.
class ReviewDetails extends StatefulWidget {
  const ReviewDetails({super.key, required this.review});

  final Review review;

  @override
  State<ReviewDetails> createState() => _ReviewDetailsState();
}

class _ReviewDetailsState extends State<ReviewDetails> {
  static const double _posterWidth = 110;
  static const double _posterHeight = 165;
  static const double _posterRadius = 6;
  static const double _avatarRadius = 22;

  bool _spoilersRevealed = false;

  Review get _review => widget.review;

  void _openMovie() {
    final int? movieId = _review.movie?.id;
    if (movieId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetails(movieId: movieId)),
    );
  }

  void _openProfile() {
    final int? userId = _review.user?.id;
    if (userId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildMovie(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildAuthor(),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMovie() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Movie? movie = _review.movie;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _openMovie,
          borderRadius: BorderRadius.circular(_posterRadius),
          child: buildPoster(
            context,
            movie?.poster,
            width: _posterWidth,
            height: _posterHeight,
            iconSize: 32,
            borderRadius: _posterRadius,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openMovie,
                child: Text(
                  movie?.title ?? "-",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                movie?.releaseDate?.year.toString() ?? "",
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              buildRating(
                context,
                _review.rating,
                size: 20,
                isLiked: _review.isLiked == true,
                isRewatch: _review.isRewatch == true,
              ),
              const SizedBox(height: 10),
              Text(
                "Watched ${formatDate(_review.loggedOn)}",
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthor() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final User? user = _review.user;

    return InkWell(
      onTap: _openProfile,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          buildAvatar(
            context,
            user?.profileImage,
            user?.username,
            radius: _avatarRadius,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? "-",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user?.fullName != null)
                  Text(
                    user!.fullName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatDate(_review.createdAt),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String content = _review.content?.trim() ?? "";
    if (content.isEmpty) {
      return Text(
        "No written review.",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
      );
    }

    if (_review.containsSpoilers == true && !_spoilersRevealed) {
      return _buildSpoilerCover();
    }

    return Text(
      content,
      style: TextStyle(color: colors.onSurface, fontSize: 15, height: 1.4),
    );
  }

  Widget _buildSpoilerCover() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => setState(() => _spoilersRevealed = true),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Contains spoilers. Tap to read.",
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
