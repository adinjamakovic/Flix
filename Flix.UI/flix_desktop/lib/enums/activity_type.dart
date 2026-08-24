import 'package:json_annotation/json_annotation.dart';

enum ActivityType {
  @JsonValue(0)
  joinedPlatform,
  @JsonValue(1)
  watchedMovie,
  @JsonValue(2)
  reviewedMovie,
  @JsonValue(3)
  likedMovie,
  @JsonValue(4)
  addedToWatchlist,
  @JsonValue(5)
  createdList,
  @JsonValue(6)
  followedUser,
  @JsonValue(7)
  requestedMovie,
  @JsonValue(8)
  joinedClash,
  @JsonValue(9)
  wonClash,
  @JsonValue(10)
  votedOnClash
}
