import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({ super.key, required this.user });

  final User user;

  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {
  static const int _columns = 4;
  static const double _posterRatio = 2 / 3;
  static const double _posterRadius = 4;
  static const double _gridSpacing = 8;

  static const double _bottomInset = 88;

  late AuthProvider _authProvider;
  late ListProvider _listProvider;

  List<Movie> _movies = List.empty();

  bool _isLoading = true;
  String? _error;

  bool get _isCurrentUser =>
      widget.user.id != null && widget.user.id == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _authProvider = context.read<AuthProvider>();
    _listProvider = context.read<ListProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int? userId = widget.user.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = "User not found";
      });
      return;
    }

    try {
      final List<Movie> movies =
          await _listProvider.getWatchlistMovies(userId: userId);

      if (!mounted) return;

      setState(() {
        _movies = movies;
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

  void _onMovieTapped(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetails(movieId: movie.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    if (_movies.isEmpty) {
      return buildMessage(
        context,
        _isCurrentUser
            ? "Your watchlist is empty. Movies you want to watch show up here."
            : "${widget.user.username ?? "This user"} hasn't added anything to their watchlist.",
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, _bottomInset),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
        childAspectRatio: _posterRatio,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) => _buildPoster(_movies[index]),
    );
  }

  Widget _buildPoster(Movie movie) {
    return Stack(
      children: [
        buildPoster(
          context,
          movie.poster,
          width: double.infinity,
          height: double.infinity,
          iconSize: 32,
          borderRadius: _posterRadius,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onMovieTapped(movie),
              borderRadius: BorderRadius.circular(_posterRadius),
            ),
          ),
        ),
      ],
    );
  }
}
