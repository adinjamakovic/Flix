import 'package:json_annotation/json_annotation.dart';

part 'review_count.g.dart';

@JsonSerializable()
class ReviewCount {
  ReviewCount(
      this.userId,
      this.movieId,
      this.totalCount,
      this.unratedCount,
      this.averageRating,
      this.ratings
      );

  /// Whichever of the two the count was asked for; the other stays null.
  final int? userId;
  final int? movieId;
  final int? totalCount;
  final int? unratedCount;
  final double? averageRating;
  final List<RatingCount>? ratings;

  int get ratedCount => (totalCount ?? 0) - (unratedCount ?? 0);

  int get maxCount => (ratings ?? [])
      .fold(0, (highest, bucket) =>
          (bucket.count ?? 0) > highest ? bucket.count! : highest);

  int countFor(double rating) {
    for (final bucket in ratings ?? <RatingCount>[]) {
      if (bucket.rating == rating) return bucket.count ?? 0;
    }

    return 0;
  }

  factory ReviewCount.fromJson(Map<String, dynamic> json) =>
      _$ReviewCountFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewCountToJson(this);
}

@JsonSerializable()
class RatingCount {
  RatingCount(this.rating, this.count);

  final double? rating;
  final int? count;

  factory RatingCount.fromJson(Map<String, dynamic> json) =>
      _$RatingCountFromJson(json);

  Map<String, dynamic> toJson() => _$RatingCountToJson(this);
}
