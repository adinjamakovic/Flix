import 'package:flix_mobile/models/movie_list_details.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class ListProvider extends BaseProvider<MovieListDetails> {
  ListProvider() : super("List");

  @override
  MovieListDetails fromJson(data) {
    return MovieListDetails.fromJson(data);
  }

  Future<SearchResult<MovieListDetails>> getUserLists({
    required int userId,
    int page = 1,
    int pageSize = 10,
    bool includeMovies = true,
    bool includeUser = false,
    bool includeTotalCount = true,
  }) {
    return get(filter: {
      "page": page,
      "pageSize": pageSize,
      "userId": userId,
      "includeMovies": includeMovies,
      "includeUser": includeUser,
      "includeTotalCount": includeTotalCount,
    });
  }
}
