import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'review.g.dart';

@JsonSerializable()
class Review {
  Review(
      this.id,
      this.user,
      this.movie,
      this.rating,
      this.isLiked,
      this.content,
      this.containsSpoilers,
      this.isDiaryEntry,
      this.isRewatch,
      this.createdAt
      );

  final int? id;

  /// Only populated when the search was sent with includeUser/includeMovie.
  final User? user;
  final Movie? movie;

  final double? rating;
  final bool? isLiked;
  final String? content;
  final bool? containsSpoilers;
  final bool? isDiaryEntry;
  final bool? isRewatch;
  final DateTime? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
