import 'package:flix_mobile/models/genre.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_user_state.dart';
import 'package:flix_mobile/models/review_count.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/providers/user_provider.dart';
import 'package:flix_mobile/screens/movie_details/actions_sheet.dart';
import 'package:flix_mobile/screens/movie_details/cast.dart';
import 'package:flix_mobile/screens/movie_details/crew.dart';
import 'package:flix_mobile/screens/movie_details/details.dart';
import 'package:flix_mobile/screens/movie_details/genre.dart';
import 'package:flix_mobile/screens/movie_details/review.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/expandable_text.dart';
import 'package:flix_mobile/widgets/rating_count.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({super.key, required this.movieId});

  final int? movieId;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails>
    with SingleTickerProviderStateMixin {
  static const String _headerPlaceholder =
      "assets/images/header_placeholder.jpg";

  static const double _headerMaxHeight = 400;

  static const _tabs = <String>["Cast", "Crew", "Details", "Genre", "Reviews"];

  late MovieProvider _movieProvider;
  late ReviewProvider _reviewProvider;
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  // The whole screen is one scroll view, so the tabs cannot be a `TabBarView` -
  // it needs a bounded height. Only the selected tab is built, sized to its own
  // content, and the page grows with it.
  late final TabController _tabController;

  Movie? _movie;
  ReviewCount? _reviewCount;
  User? _currentUser;
  MovieUserState? _movieState;

  bool _isLoading = true;
  String? _error;

  int _reviewGeneration = 0;

  @override
  void initState() {
    super.initState();

    _movieProvider = context.read<MovieProvider>();
    _reviewProvider = context.read<ReviewProvider>();
    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();

    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));

    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int? movieId = widget.movieId;

    if (movieId == null) {
      setState(() {
        _isLoading = false;
        _error = "Movie not found";
      });
      return;
    }

    try {
      final Movie movie = await _movieProvider.getById(movieId);
      final ReviewCount reviewCount = await _reviewProvider
          .getMovieReviewCount(movieId);
      final User? currentUser = await _loadCurrentUser();
      final MovieUserState movieState = await _loadMovieState(movieId);

      if (!mounted) return;

      setState(() {
        _movie = movie;
        _reviewCount = reviewCount;
        _currentUser = currentUser;
        _movieState = movieState;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  Future<void> _reload() async {
    final int? movieId = widget.movieId;
    if (movieId == null) return;

    try {
      final ReviewCount reviewCount = await _reviewProvider
          .getMovieReviewCount(movieId);
      final MovieUserState movieState = await _loadMovieState(movieId);

      if (!mounted) return;

      setState(() {
        _reviewCount = reviewCount;
        _movieState = movieState;
        _reviewGeneration++;
      });
    } catch (e) {
      if (!mounted) return;
      showSnack(context, errorText(e));
    }
  }

  // Only the action bar's avatar depends on this, so a failure here must not
  // take the whole screen down with it.
  Future<User?> _loadCurrentUser() async {
    if (!_authProvider.isAuthenticated) return null;

    try {
      return await _userProvider.getCurrentUserProfile();
    } catch (_) {
      return null;
    }
  }

  Future<MovieUserState> _loadMovieState(int movieId) async {
    if (!_authProvider.isAuthenticated) return MovieUserState.empty(movieId);

    try {
      return await _reviewProvider.getMovieState(movieId);
    } catch (_) {
      return MovieUserState.empty(movieId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: buildMessage(
          context,
          _error!,
          action: TextButton(onPressed: _load, child: const Text("Try again")),
        ),
      );
    }

    return Scaffold(body: _buildMovie(_movie!));
  }

  Widget _buildMovie(Movie movie) {
    final colorScheme = Theme.of(context).colorScheme;

    final genres = movie.genres ?? const <Genre>[];
    final genreCount = genres.length < 2 ? genres.length : 2;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildheader(movie),
            _buildBody(movie, colorScheme, genreCount, genres),
            Divider(),
            _buildRatings(context),
            Divider(),
            _buildActionBar(context, movie),
            Divider(),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs.map((label) => Tab(text: label)).toList(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildTab(movie),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(Movie movie) {
    switch (_tabController.index) {
      case 0:
        return CastTab(cast: movie.cast ?? const []);
      case 1:
        return CrewTab(directors: movie.directors ?? const []);
      case 2:
        return DetailsTab(movie: movie);
      case 3:
        return GenreTab(genres: movie.genres ?? const []);
      default:
        return ReviewTab(
          key: ValueKey(_reviewGeneration),
          movieId: widget.movieId!,
        );
    }
  }

  Widget _buildActionBar(BuildContext context, Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openActionsSheet(movie),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                buildAvatar(
                  context,
                  _currentUser?.profileImage,
                  _currentUser?.username ?? _authProvider.username,
                  radius: 14,
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildActionBarLabel(colors)),
                const SizedBox(width: 8),
                Icon(Icons.more_horiz, color: colors.onSurfaceVariant, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Once the user has recorded anything, the bar stops inviting them to and
  // shows what they recorded instead - the "you rated this" state.
  Widget _buildActionBarLabel(ColorScheme colors) {
    final MovieUserState? state = _movieState;

    if (state == null || !(state.watched || state.liked || state.stars > 0)) {
      return Text(
        "Rate, log, review, add to list + more",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Row(
      children: [
        Icon(Icons.remove_red_eye, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        buildRating(
          context,
          state.stars,
          emptyLabel: "Watched",
          isLiked: state.liked,
        ),
      ],
    );
  }

  Future<void> _openActionsSheet(Movie movie) async {
    await showMovieActionsSheet(
      context,
      movie,
      _movieState ?? MovieUserState.empty(movie.id),
    );

    await _reload();
  }

  Widget _buildRatings(BuildContext context) {
    final ReviewCount? counts = _reviewCount;
    if (counts == null) {
      return buildEmpty(context, "No ratings yet");
    }

    return RatingCountChart(counts: counts);
  }

  Padding _buildBody(Movie movie, ColorScheme colorScheme, int genreCount, List<Genre> genres) {
    return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title ?? "-",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "${movie.releaseDate?.year.toString() ?? ""}   DIRECTED BY",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            debugPrint("TODO: cast screen");
                          },
                          child: Text(
                            movie.director?.fullName ?? "Unknown",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Duration: ${_movie?.durationMinutes ?? "unknown"} minutes",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: genreCount,
                        itemBuilder: (context, index) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                genres[index].name ?? "-",
                                style: TextStyle(
                                  color: colorScheme.onSecondaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpandableText(
                  text: movie.description ?? "No description available.",
                  collapsedLines: 4,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
  }

  Stack _buildheader(Movie movie) {
    return Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: _headerMaxHeight,
                ),
                child: movie.headerImage == null
                    ? Image.asset(_headerPlaceholder)
                    : Image.network(
                        movie.headerImage!,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(_headerPlaceholder),
                      ),
              ),
              IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: Icon(Icons.arrow_back),
              ),
            ],
          );
  }
}
