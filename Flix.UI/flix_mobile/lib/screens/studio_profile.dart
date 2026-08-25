import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/studio.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/providers/studio_provider.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudioProfile extends StatefulWidget {
  const StudioProfile({super.key, required this.studioId});

  final int? studioId;

  @override
  State<StudioProfile> createState() => _StudioProfileState();
}

class _StudioProfileState extends State<StudioProfile> {
  static const double _logoHeight = 120;

  static const int _pageSize = 20;
  static const double _loadMoreThreshold = 300;

  static const double _posterWidth = 72;
  static const double _posterHeight = 108;

  late StudioProvider _studioProvider;
  late MovieProvider _movieProvider;

  final ScrollController _scrollController = ScrollController();

  Studio? _studio;

  final List<Movie> _movies = <Movie>[];
  int _movieCount = 0;
  int _page = 1;
  bool _isLoadingMore = false;

  bool _isLoading = true;
  String? _error;

  bool get _hasMorePages => _movies.length < _movieCount;

  @override
  void initState() {
    super.initState();

    _studioProvider = context.read<StudioProvider>();
    _movieProvider = context.read<MovieProvider>();

    _scrollController.addListener(_onScroll);

    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int? studioId = widget.studioId;

    if (studioId == null) {
      setState(() {
        _isLoading = false;
        _error = "Studio not found";
      });
      return;
    }

    try {
      final List<dynamic> results = await Future.wait([
        _studioProvider.getById(studioId),
        _movieProvider.get(filter: _buildFilter(1)),
      ]);

      if (!mounted) return;

      final SearchResult<Movie> movies = results[1] as SearchResult<Movie>;

      setState(() {
        _studio = results[0] as Studio;
        _movies
          ..clear()
          ..addAll(itemsOf(movies));
        _movieCount = movies.totalCount ?? _movies.length;
        _page = 1;
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

  Map<String, dynamic> _buildFilter(int page) {
    return {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      // The rating on each row is averaged from the reviews, which the API only
      // loads when this is set.
      "includeReviews": true,
      "isEnabled": true,
      "studioId": widget.studioId,
    };
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore || !_hasMorePages) return;

    final double remaining = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;

    if (remaining <= _loadMoreThreshold) _loadMoreMovies();
  }

  Future<void> _loadMoreMovies() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final SearchResult<Movie> data = await _movieProvider.get(
        filter: _buildFilter(_page + 1),
      );

      if (!mounted) return;

      setState(() {
        _movies.addAll(itemsOf(data));
        _movieCount = data.totalCount ?? _movies.length;
        _page += 1;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
      // The studio itself is already on screen, so a failed next page is a
      // snack rather than the whole screen turning into an error.
      showSnack(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    final ColorScheme colors = Theme.of(context).colorScheme;
    final Studio studio = _studio!;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _buildLogo(studio),
          const SizedBox(height: 16),
          Text(
            studio.name ?? "Unknown",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            studio.description?.trim().isNotEmpty == true
                ? studio.description!.trim()
                : "No description available.",
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 28),
          ..._buildFilmography(),
        ],
      ),
    );
  }

  List<Widget> _buildFilmography() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return [
      Row(
        children: [
          Text(
            "Movies",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _movieCount.toString(),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Divider(),
      if (_movies.isEmpty)
        buildEmpty(context, "No movies listed for this studio yet.")
      else
        for (int i = 0; i < _movies.length; i++) ...[
          if (i > 0) const Divider(),
          _buildMovieRow(_movies[i]),
        ],
      if (_isLoadingMore)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
    ];
  }

  Widget _buildMovieRow(Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int? year = movie.releaseDate?.year;

    return InkWell(
      onTap: () => _openMovie(movie),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPoster(
              context,
              movie.poster,
              width: _posterWidth,
              height: _posterHeight,
              iconSize: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? "-",
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    year?.toString() ?? "-",
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  buildRating(
                    context,
                    movie.rating,
                    size: 18,
                    emptyLabel: "Not rated yet",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMovie(Movie movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetails(movieId: movie.id),
      ),
    );

    // A rating left on the way back changes the row it came from.
    if (mounted) await _load();
  }

  Widget _buildLogo(Studio studio) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Uri? logo = httpUri(studio.logo);

    if (logo == null) {
      return Icon(
        Icons.business_outlined,
        size: _logoHeight * 0.5,
        color: colors.onSurfaceVariant,
      );
    }

    return Image.network(
      logo.toString(),
      height: _logoHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.business_outlined,
        size: _logoHeight * 0.5,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
