import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_recommendation.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class MovieRecommenderProvider extends BaseProvider<MovieRecommendation> {
  MovieRecommenderProvider() : super("MovieRecommendations");

  @override
  MovieRecommendation fromJson(data) {
    return MovieRecommendation.fromJson(data);
  }

  Future<List<MovieRecommendation>> getRecommendationsForUser() async {
    var result = await get(action: "GetRecommendationsForUser");

    return result.items ?? List<MovieRecommendation>.empty();
  }

  Future<List<Movie>> getRecommendedMoviesForUser() async {
    var recommendations = await getRecommendationsForUser();

    return recommendations
        .where((recommendation) => recommendation.recommendedMovie != null)
        .map((recommendation) => recommendation.recommendedMovie!)
        .toList();
  }
}
