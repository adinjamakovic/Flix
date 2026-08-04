import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'genre.g.dart';

@JsonSerializable()
class Genre {
  Genre(
      this.id,
      this.name
      );

  final int? id;
  final String? name;

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  Map<String, dynamic> toJson() => _$GenreToJson(this);
}
