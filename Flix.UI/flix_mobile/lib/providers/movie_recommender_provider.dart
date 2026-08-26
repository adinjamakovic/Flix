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

    return (result.items ?? List<MovieRecommendation>.empty())
        .where((recommendation) => recommendation.recommendedMovie != null)
        .toList();
  }
}
