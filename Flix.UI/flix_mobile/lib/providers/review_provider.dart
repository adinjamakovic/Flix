import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/review_count.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }

  Future<ReviewCount> getUserReviewCount() async {
    var data = await getObject(action: "UserReviewCount");

    return ReviewCount.fromJson(data);
  }

  Future<ReviewCount> getMovieReviewCount(int movieId) async {
    var data = await getObject(
      action: "MovieReviewCount",
      filter: {"movieId": movieId},
    );

    return ReviewCount.fromJson(data);
  }
}
