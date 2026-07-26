import 'package:json_annotation/json_annotation.dart';

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
      this.countryId,
      this.languageId
      );


  final int? id;
  final String? title;
  final String? description;
  final String? trailerUrl;
  final DateTime? releaseDate;
  final int? durationMinutes;
  final int? views;
  final bool? isEnabled;
  final int? countryId;
  final int? languageId;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  Map<String, dynamic> toJson() => _$MovieToJson(this);
}