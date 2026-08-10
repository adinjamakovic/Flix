import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super("Movie");

  @override
  Movie fromJson(data) {
    return Movie.fromJson(data);
  }
}
