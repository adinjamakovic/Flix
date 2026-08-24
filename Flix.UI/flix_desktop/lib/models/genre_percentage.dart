import 'package:flix_desktop/models/genre.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genre_percentage.g.dart';

@JsonSerializable()
class GenrePercentage {
  GenrePercentage(this.genre, this.percentage);

  final Genre? genre;
  final double? percentage;

  factory GenrePercentage.fromJson(Map<String, dynamic> json) =>
      _$GenrePercentageFromJson(json);

  Map<String, dynamic> toJson() => _$GenrePercentageToJson(this);
}
