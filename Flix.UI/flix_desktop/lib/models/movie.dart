import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/genre.dart';
import 'package:flix_desktop/models/language.dart';
import 'package:flix_desktop/models/movie_credit.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'movie.g.dart';

@JsonSerializable()
class Movie {
  Movie(
      this.id,
      this.title,
      this.description,
      this.trailerUrl,
      this.releaseDate,
      this.durationMinutes,
      this.views,
      this.isEnabled,
      this.country,
      this.language,
      this.rating,
      this.reviewCount,
      this.directors,
      this.cast,
      this.genres,
      this.poster,
      this.headerImage
      );


  final int? id;
  final String? title;
  final String? description;
  final String? trailerUrl;
  final DateTime? releaseDate;
  final int? durationMinutes;
  final int? views;
  final bool? isEnabled;
  final double? rating;
  final int? reviewCount;
  final Country? country;
  final Language? language;
  final List<CastMember>? directors;
  final List<MovieCredit>? cast;
  final List<Genre>? genres;
  final String? poster;
  final String? headerImage;

  /// A movie can have several directors, the UI only shows the first one.
  CastMember? get director =>
      (directors == null || directors!.isEmpty) ? null : directors!.first;

  String? get directorName => director?.fullName;

  String? get genreNames {
    final List<String> names = (genres ?? [])
        .where((genre) => genre.name != null && genre.name!.trim().isNotEmpty)
        .map((genre) => genre.name!.trim())
        .toList();

    return names.isEmpty ? null : names.join(", ");
  }

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
