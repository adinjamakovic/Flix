import 'package:flix_mobile/models/genre.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }
}
