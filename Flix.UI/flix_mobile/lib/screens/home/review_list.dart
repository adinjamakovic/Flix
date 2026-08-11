import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  // Both sections are a glance at a feed rather than the whole of it, so each
  // one shows a single page and there is nothing to page through.
  //
  // `ReviewService.GetDataSource()` orders by `CreatedAt` descending, so page 1
  // is already the newest reviews and nothing has to be re-ordered here.
  static const int _feedPageSize = 10;

  static const double _posterWidth = 64;
  static const double _posterHeight = 96;
  static const double _avatarRadius = 11;

  late ReviewProvider _reviewProvider;
  late AuthProvider _authProvider;

  List<Review> _followingReviews = List.empty();

  // The movie the user reviewed most recently, and what other people said
  // about it.
  Movie? _latestMovie;
  List<Review> _latestMovieReviews = List.empty();

  // Reviews flagged as containing spoilers stay covered until tapped; this is
  // the set of ids the user has uncovered.
  final Set<int> _revealedSpoilers = <int>{};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Both sections are relative to the signed-in user, so an anonymous session
    // has nothing to ask the API for. The id comes off the `Id` claim on the
    // token, and both searches are keyed on it.
    final int? userId = _authProvider.userId;

    if (userId == null) {
      setState(() {
        _followingReviews = List.empty();
        _latestMovie = null;
        _latestMovieReviews = List.empty();
        _isLoading = false;
      });
      return;
    }

    try {
      // The followed feed and the user's own reviews are independent, so both
      // go out together; the second section's movie is only known once the
      // user's own reviews have landed.
      final Future<SearchResult<Review>> followingRequest =
          _reviewProvider.get(filter: _followingFilter(userId));
      final Future<SearchResult<Review>> ownRequest =
          _reviewProvider.get(filter: _ownReviewsFilter(userId));

      final List<Review> following = _itemsOf(await followingRequest);
      final List<Review> own = _itemsOf(await ownRequest);

      final Movie? latestMovie = own.isEmpty ? null : own.first.movie;
      final List<Review> latestMovieReviews =
          await _loadReviewsOf(latestMovie, userId);

      if (!mounted) return;

      setState(() {
        _followingReviews = following;
        _latestMovie = latestMovie;
        _latestMovieReviews = latestMovieReviews;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Map<String, dynamic> _followingFilter(int userId) => {
        "page": 1,
        "pageSize": _feedPageSize,
        "includeUser": true,
        "includeMovie": true,
        "followedByUserId": userId,
      };

  Map<String, dynamic> _ownReviewsFilter(int userId) => {
        "page": 1,
        "pageSize": 1,
        "includeMovie": true,
        "userId": userId,
      };

  Future<List<Review>> _loadReviewsOf(Movie? movie, int userId) async {
    final int? movieId = movie?.id;
    if (movieId == null) return List.empty();

    final SearchResult<Review> result = await _reviewProvider.get(filter: {
      "page": 1,
      // Nothing stops a user reviewing the same movie twice - a rewatch is
      // exactly that - so a spare slot keeps the section full once their own
      // reviews are dropped below.
      "pageSize": _feedPageSize + 1,
      "includeUser": true,
      "includeMovie": true,
      "movieId": movieId,
    });

    return _itemsOf(result)
        .where((r) => !_isBy(r, userId))
        .take(_feedPageSize)
        .toList();
  }

  bool get _isSignedIn => _authProvider.userId != null;

  List<Review> _itemsOf(SearchResult<Review> result) =>
      result.items ?? List<Review>.empty();

  bool _isBy(Review review, int userId) => review.user?.id == userId;

  String _formatDate(DateTime? date) {
    if (date == null) return "-";

    final DateTime local = date.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');

    return "$day/$month/${local.year}";
  }

  void _onReviewTapped(Review review) {
    // TODO: open the review details screen once it exists.
    debugPrint("TODO: open review ${review.id}");
  }

  void _toggleSpoilers(Review review) {
    final int? id = review.id;
    if (id == null) return;

    setState(() {
      if (!_revealedSpoilers.remove(id)) _revealedSpoilers.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildMessage(
        _error!,
        action: TextButton(
          onPressed: _load,
          child: const Text("Try again"),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildSection(
            label: "From people you follow",
            child: _buildFollowingReviews(),
          ),
          _buildSection(
            label: _latestMovie?.title == null
                ? "From your last review"
                : "More on ${_latestMovie!.title}",
            child: _buildLatestMovieReviews(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String label, required Widget child}) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
          child: child,
        ),
      ],
    );
  }

  Widget _buildFollowingReviews() {
    if (_followingReviews.isEmpty) {
      return _buildEmpty(
        !_isSignedIn
            ? "Sign in to see what the people you follow are watching."
            : "Nobody you follow has written a review yet.",
      );
    }

    return _buildFeed(_followingReviews);
  }

  Widget _buildLatestMovieReviews() {
    if (!_isSignedIn) {
      return _buildEmpty("Sign in to see reviews of the movies you watch.");
    }

    if (_latestMovie == null) {
      return _buildEmpty(
        "Review a movie and you'll see what everybody else made of it here.",
      );
    }

    if (_latestMovieReviews.isEmpty) {
      return _buildEmpty(
        "You're the only one who has reviewed ${_latestMovie!.title ?? "it"} so far.",
      );
    }

    return _buildFeed(_latestMovieReviews);
  }

  Widget _buildFeed(List<Review> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final Review review in reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildReviewCard(review),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onReviewTapped(review),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(review.movie),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.movie?.title ?? "-",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildByline(review),
                  const SizedBox(height: 8),
                  _buildRating(review),
                  const SizedBox(height: 10),
                  _buildContent(review),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // `Movie.poster` is the read-only SAS URL the API hands back, not a path.
  Widget _buildPoster(Movie? movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Uri? uri = Uri.tryParse(movie?.poster ?? "");
    final bool isNetworkImage =
        uri != null && (uri.scheme == "http" || uri.scheme == "https");

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: _posterWidth,
        height: _posterHeight,
        child: isNetworkImage
            ? Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPosterPlaceholder(colors),
              )
            : _buildPosterPlaceholder(colors),
      ),
    );
  }

  Widget _buildPosterPlaceholder(ColorScheme colors) {
    return ColoredBox(
      color: colors.surfaceContainer,
      child: Icon(
        Icons.movie_outlined,
        color: colors.onSurfaceVariant,
        size: 26,
      ),
    );
  }

  Widget _buildByline(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        _buildAvatar(review),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            review.user?.username ?? "-",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDate(review.createdAt),
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  // `User.profileImage` is a SAS URL like the poster; the initial stands in
  // while it is missing or fails to load.
  Widget _buildAvatar(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String username = review.user?.username ?? "";
    final Uri? uri = Uri.tryParse(review.user?.profileImage ?? "");
    final bool isNetworkImage =
        uri != null && (uri.scheme == "http" || uri.scheme == "https");

    return CircleAvatar(
      radius: _avatarRadius,
      backgroundColor: colors.surfaceContainerHigh,
      foregroundImage: isNetworkImage ? NetworkImage(uri.toString()) : null,
      child: Text(
        username.isEmpty ? "?" : username.characters.first.toUpperCase(),
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Half-star steps, plus the marks a review can carry: liked, and rewatched.
  Widget _buildRating(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final int halfStars = (((review.rating ?? 0).clamp(0, 5)) * 2).round();
    final int fullStars = halfStars ~/ 2;

    return Row(
      children: [
        if (halfStars == 0)
          Text(
            "Not rated",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          )
        else ...[
          ...List.generate(
            fullStars,
            (index) => Icon(Icons.star, size: 16, color: colors.onSurface),
          ),
          if (halfStars.isOdd)
            Icon(Icons.star_half, size: 16, color: colors.onSurface),
        ],
        if (review.isLiked == true) ...[
          const SizedBox(width: 8),
          Icon(Icons.favorite, size: 14, color: colors.primary),
        ],
        if (review.isRewatch == true) ...[
          const SizedBox(width: 8),
          Icon(Icons.replay, size: 14, color: colors.onSurfaceVariant),
        ],
      ],
    );
  }

  Widget _buildContent(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String content = review.content?.trim() ?? "";
    if (content.isEmpty) {
      return Text(
        "No written review.",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
      );
    }

    if (review.containsSpoilers == true &&
        !_revealedSpoilers.contains(review.id)) {
      return _buildSpoilerCover(review);
    }

    return Text(
      content,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: colors.onSurface, fontSize: 14, height: 1.3),
    );
  }

  Widget _buildSpoilerCover(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _toggleSpoilers(review),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _buildEmpty(String message) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        message,
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
      ),
    );
  }

  Widget _buildMessage(String message, {Widget? action}) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
