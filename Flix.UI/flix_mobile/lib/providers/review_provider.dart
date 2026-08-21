import 'package:flix_mobile/models/movie_user_state.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/review_count.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }

  Future<ReviewCount> getUserReviewCount({int? userId}) async {
    var data = await getObject(
      action: "UserReviewCount",
      filter: userId == null ? null : {"userId": userId},
    );

    return ReviewCount.fromJson(data);
  }

  Future<ReviewCount> getMovieReviewCount(int movieId) async {
    var data = await getObject(
      action: "MovieReviewCount",
      filter: {"movieId": movieId},
    );

    return ReviewCount.fromJson(data);
  }

  Future<MovieUserState> getMovieState(int movieId) async {
    var data = await getObject(
      action: "MovieState",
      filter: {"movieId": movieId},
    );

    return MovieUserState.fromJson(data);
  }

  Future<MovieUserState> saveStandingReview({
    required int movieId,
    required bool isWatched,
    required bool isLiked,
    double? rating,
  }) async {
    var data = await insertObject("StandingReview", {
      "movieId": movieId,
      "isWatched": isWatched,
      "isLiked": isLiked,
      "rating": rating,
    });

    return MovieUserState.fromJson(data);
  }
}
