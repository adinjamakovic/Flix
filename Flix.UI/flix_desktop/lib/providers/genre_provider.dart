import 'package:flix_desktop/models/genre.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }
}
