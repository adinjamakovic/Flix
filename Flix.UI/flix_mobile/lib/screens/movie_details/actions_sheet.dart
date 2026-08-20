import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_user_state.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/screens/movie_details/log_form.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/star_rating_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Every action in the sheet writes as it is tapped, and the sheet can also be
/// dismissed with a drag, so the caller refreshes once it is gone rather than
/// being told what happened.
Future<void> showMovieActionsSheet(
  BuildContext context,
  Movie movie,
  MovieUserState state,
) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surfaceContainerLow,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => MovieActionsSheet(movie: movie, state: state),
  );
}

class MovieActionsSheet extends StatefulWidget {
  const MovieActionsSheet({
    super.key,
    required this.movie,
    required this.state,
  });

  final Movie movie;
  final MovieUserState state;

  @override
  State<MovieActionsSheet> createState() => _MovieActionsSheetState();
}

class _MovieActionsSheetState extends State<MovieActionsSheet> {
  late ReviewProvider _reviewProvider;
  late ListProvider _listProvider;

  late bool _isWatched = widget.state.watched;
  late bool _isLiked = widget.state.liked;
  late bool _isInWatchlist = widget.state.inWatchlist;
  late double _rating = widget.state.stars;
  late int _diaryEntryCount = widget.state.diaryEntryCount ?? 0;

  bool _isSaving = false;

  int? get _movieId => widget.movie.id;

  @override
  void initState() {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();
    _listProvider = context.read<ListProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(colors),
          _buildToggles(colors),
          const Divider(),
          _buildStars(),
          const Divider(),
          _buildItem(
            icon: Icons.subject,
            label: "Review or log...",
            onTap: _openLogForm,
          ),
          const Divider(),
          _buildItem(
            icon: Icons.playlist_add,
            label: "Add to a list...",
            onTap: () => _close(() => debugPrint("TODO: add to a list")),
          ),
          const Divider(),
          _buildItem(
            icon: Icons.image_outlined,
            label: "View poster",
            onTap: _viewPoster,
          ),
          const Divider(),
          _buildItem(
            icon: Icons.report_gmailerrorred_outlined,
            label: "Report an issue...",
            onTap: () => _close(() => debugPrint("TODO: report an issue")),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You're currently rating:",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            titleWithYear(widget.movie.title, widget.movie.releaseDate),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggles(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildToggle(
            colors,
            icon: Icons.remove_red_eye_outlined,
            activeIcon: Icons.remove_red_eye,
            label: "Watch",
            isActive: _isWatched,
            // Unmarking a movie takes the whole standing opinion with it - a
            // rating left behind would keep the API calling it watched.
            onTap: () => _isWatched
                ? _saveStanding(isWatched: false, isLiked: false, rating: 0)
                : _saveStanding(isWatched: true),
          ),
          _buildToggle(
            colors,
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: "Like",
            isActive: _isLiked,
            onTap: () => _saveStanding(isLiked: !_isLiked),
          ),
          _buildToggle(
            colors,
            icon: Icons.access_time,
            activeIcon: Icons.access_time_filled,
            label: "Watchlist",
            isActive: _isInWatchlist,
            onTap: _toggleWatchlist,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    ColorScheme colors, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color = isActive ? colors.primary : colors.onSurface;

    return Expanded(
      child: InkWell(
        onTap: _isSaving ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(isActive ? activeIcon : icon, color: color, size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: StarRatingInput(
        rating: _rating,
        enabled: !_isSaving,
        onChanged: (value) => _saveStanding(rating: value),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }

  // The toggles and the stars all edit the one standing review, so they go
  // through a single write that sends the whole of it and takes the state the
  // API leaves the movie in.
  Future<void> _saveStanding({
    bool? isWatched,
    bool? isLiked,
    double? rating,
  }) async {
    final int? movieId = _movieId;
    if (movieId == null || _isSaving) return;

    final double nextRating = rating ?? _rating;
    final bool nextLiked = isLiked ?? _isLiked;

    // Rating or liking a movie is a statement about one that has been seen, so
    // the eye follows them without the user having to press it.
    final bool nextWatched =
        isWatched ?? (_isWatched || nextRating > 0 || nextLiked);

    setState(() => _isSaving = true);

    try {
      final MovieUserState state = await _reviewProvider.saveStandingReview(
        movieId: movieId,
        isWatched: nextWatched,
        isLiked: nextLiked,
        rating: nextRating == 0 ? null : nextRating,
      );

      if (!mounted) return;

      setState(() {
        _apply(state);
        _isSaving = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      showSnack(context, errorText(e));
    }
  }

  Future<void> _toggleWatchlist() async {
    final int? movieId = _movieId;
    if (movieId == null || _isSaving) return;

    final bool adding = !_isInWatchlist;

    setState(() => _isSaving = true);

    try {
      if (adding) {
        await _listProvider.addToWatchlist(movieId);
      } else {
        await _listProvider.removeFromWatchlist(movieId);
      }

      if (!mounted) return;

      setState(() {
        _isInWatchlist = adding;
        _isSaving = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      showSnack(context, errorText(e));
    }
  }

  void _apply(MovieUserState state) {
    _isWatched = state.watched;
    _isLiked = state.liked;
    _isInWatchlist = state.inWatchlist;
    _rating = state.stars;
    _diaryEntryCount = state.diaryEntryCount ?? _diaryEntryCount;
  }

  // The form goes on top of the sheet rather than replacing it, so the entry is
  // already written by the time the sheet closes behind it.
  Future<void> _openLogForm() async {
    final int? movieId = _movieId;
    if (movieId == null) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LogMovieForm(
          movie: widget.movie,
          state: MovieUserState(
            movieId,
            _isWatched,
            _isLiked,
            _rating == 0 ? null : _rating,
            _isInWatchlist,
            _diaryEntryCount,
          ),
        ),
      ),
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _close(VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  Future<void> _viewPoster() async {
    final Uri? poster = httpUri(widget.movie.poster);

    // The sheet's own context is gone once it is popped, so both the snack bar
    // and the dialog go on the navigator that hosted it.
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();

    if (poster == null) {
      showSnack(navigator.context, "This movie has no poster yet");
      return;
    }

    await showDialog<void>(
      context: navigator.context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(
              poster.toString(),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  buildMessage(context, "The poster could not be loaded"),
            ),
          ),
        ),
      ),
    );
  }
}
