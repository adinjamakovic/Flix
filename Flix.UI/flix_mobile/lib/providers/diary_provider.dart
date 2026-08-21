import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class DiaryProvider extends BaseProvider<Review> {
  DiaryProvider() : super("Diary");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }

  Future<SearchResult<Review>> getUserDiary({
    required int userId,
    int page = 1,
    int pageSize = 10,
    bool includeTotalCount = true,
  }) {
    return get(filter: {
      "page": page,
      "pageSize": pageSize,
      "userId": userId,
      "includeTotalCount": includeTotalCount,
    });
  }

  Future<Review> addToDiary({
    required int movieId,
    required DateTime watchedOn,
    double? rating,
    bool isLiked = false,
    String? content,
    bool containsSpoilers = false,
    bool isRewatch = false,
  }) {
    return insert({
      "movieId": movieId,
      "watchedOn": watchedOn,
      "rating": rating,
      "isLiked": isLiked,
      "content": content,
      "containsSpoilers": containsSpoilers,
      "isRewatch": isRewatch,
    });
  }
}
