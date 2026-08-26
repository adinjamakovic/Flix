import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_recommendation.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/providers/movie_recommender_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/screens/review_details.dart';
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
  Map<int, String> _recommendationReasons = const {};
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
      final Future<List<Review>> friendReviews = _optional(
          _reviewProvider.get(action: "LatestFromFriends").then(itemsOf<Review>));

      final List<Object> results = await Future.wait([
        _movieRecommenderProvider.getRecommendationsForUser(),
        _movieProvider.get(action: "PopularThisWeek").then(itemsOf<Movie>),
        _optional(_movieProvider
            .get(action: "PopularWithFriends")
            .then(itemsOf<Movie>)),
      ]);
      final List<Review> reviews = await friendReviews;
      if(!mounted) return;

      final List<MovieRecommendation> recommendations =
          results[0] as List<MovieRecommendation>;

      setState(() {
        _recommendedMovies = recommendations
            .map((recommendation) => recommendation.recommendedMovie!)
            .toList();
        _recommendationReasons = {
          for (final recommendation in recommendations)
            if (recommendation.recommendedMovie?.id != null &&
                recommendation.reason != null)
              recommendation.recommendedMovie!.id!: recommendation.reason!,
        };
        _popularThisWeek = results[1] as List<Movie>;
        _popularWithFriends = results[2] as List<Movie>;
        _newReviewsFromFriends = reviews;
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

  // The friend rows are an extra rather than the screen, so a failure there
  // leaves the row empty instead of taking the whole home screen down.
  Future<List<T>> _optional<T>(Future<List<T>> request) async {
    try {
      return await request;
    } catch (_) {
      return List<T>.empty();
    }
  }

  void _onMovieTapped(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetails(movieId: movie.id)),
    );
  }

  void _onReviewTapped(Review review) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetails(review: review)));
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
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
              movies: _recommendedMovies,
              onMovieTap: _onMovieTapped,
              captionOf: (movie) => _recommendationReasons[movie.id],
            ),
            const SizedBox(height: 12),
            MovieSideScroll(
              title: "Popular this week",
              movies: _popularThisWeek,
              onMovieTap: _onMovieTapped,
            ),
            const SizedBox(height: 12),
            if (_newReviewsFromFriends.isNotEmpty) ...[
              ReviewSideScroll(
                title: "New reviews from friends",
                reviews: _newReviewsFromFriends,
                onReviewTap: _onReviewTapped,
                isUserProfile: false,
              ),
              const SizedBox(height: 12),
            ],
            if (_popularWithFriends.isNotEmpty)
              MovieSideScroll(
                title: "Popular with friends",
                movies: _popularWithFriends,
                onMovieTap: _onMovieTapped,
              ),
          ],
      )
    );
  }
}
