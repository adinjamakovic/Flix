import 'package:flix_mobile/enums/list_type.dart';
import 'package:flix_mobile/models/movie.dart';
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
    ListType? type,
    bool includeMovies = true,
    bool includeUser = false,
    bool includeTotalCount = true,
  }) {
    return get(filter: {
      "page": page,
      "pageSize": pageSize,
      "userId": userId,
      "type": type?.index,
      "includeMovies": includeMovies,
      "includeUser": includeUser,
      "includeTotalCount": includeTotalCount,
    });
  }

  Future<void> addToList(
    int movieId, {
    int? listId,
    ListType type = ListType.custom,
  }) =>
      postJson("AddToList", {
        "movieId": movieId,
        "listId": listId,
        "type": type.index,
      });

  Future<void> removeFromWatchlist(int movieId) =>
      deleteAction("Watchlist/$movieId");

  Future<List<Movie>> getWatchlistMovies({required int userId}) async {
    final SearchResult<MovieListDetails> result = await getUserLists(
      userId: userId,
      pageSize: 1,
      type: ListType.watchlist,
      includeTotalCount: false,
    );

    final List<MovieListDetails> lists = result.items ?? List.empty();

    if (lists.isEmpty) return List<Movie>.empty();

    return lists.first.movies ?? List<Movie>.empty();
  }
}
