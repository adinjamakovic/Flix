import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/providers/movie_recommender_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/movie_side_scroll.dart';
import 'package:flix_mobile/widgets/review_side_scroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  late ReviewProvider _reviewProvider;
  late MovieProvider _movieProvider;
  late AuthProvider _authProvider;
  late MovieRecommenderProvider _movieRecommenderProvider;

  List<Movie> _recommendedMovies = List.empty();
  List<Movie> _popularThisWeek = List.empty();
  List<Review> _newReviewsFromFriends = List.empty();
  List<Movie> _popularWithFriends = List.empty();

  bool _isLoading = true;
  String? _error;

  @override
  void initState()
  {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();
    _movieRecommenderProvider = context.read<MovieRecommenderProvider>();
    _movieProvider = context.read<MovieProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }
  
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if(!_authProvider.isAuthenticated)
    {
      setState(() {
        _isLoading = false;
        _error = "User not logged in";
      });
      return;
    }

    try {
      final Future<List<Review>> friendReviews =
          _optional(_reviewProvider.getList("LatestFromFriends"));

      final List<List<Movie>> results = await Future.wait([
        _movieRecommenderProvider.getRecommendedMoviesForUser(),
        _movieProvider.getList("PopularThisWeek"),
        _optional(_movieProvider.getList("PopularWithFriends")),
      ]);
      final List<Review> reviews = await friendReviews;
      if(!mounted) return;

      setState(() {
        _recommendedMovies = results[0];
        _popularThisWeek = results[1];
        _popularWithFriends = results[2];
        _newReviewsFromFriends = reviews;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }

  }

  // The friend rows are an extra rather than the screen, so a failure there
  // leaves the row empty instead of taking the whole home screen down.
  Future<List<T>> _optional<T>(Future<List<T>> request) async {
    try {
      return await request;
    } on Exception {
      return List<T>.empty();
    }
  }

  void _onMovieTapped(Movie movie) {
    // TODO: open the movie details screen once it exists.
    debugPrint("TODO: open details for movie ${movie.id}");
  }

  void _onReviewTapped(Review review) {
    // TODO: open the review details screen once it exists.
    debugPrint("TODO: open review ${review.id}");
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if(_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(
          onPressed: _authProvider.isAuthenticated ? 
          _load : () {
            Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false, 
                      );
          }, 
          child: const Text("Try again"))
      );
    }

    return RefreshIndicator(
      onRefresh: _load, 
      child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            MovieSideScroll(
              title: "Recommended for you",
              Movies: _recommendedMovies,
              onMovieTap: _onMovieTapped,
            ),
            const SizedBox(height: 12),
            MovieSideScroll(
              title: "Popular this week",
              Movies: _popularThisWeek,
              onMovieTap: _onMovieTapped,
            ),
            const SizedBox(height: 12),
            if (_newReviewsFromFriends.isNotEmpty) ...[
              ReviewSideScroll(
                title: "New reviews from friends",
                reviews: _newReviewsFromFriends,
                onReviewTap: _onReviewTapped,
              ),
              const SizedBox(height: 12),
            ],
            if (_popularWithFriends.isNotEmpty)
              MovieSideScroll(
                title: "Popular with friends",
                Movies: _popularWithFriends,
                onMovieTap: _onMovieTapped,
              ),
          ],
      )
    );
  }
}
