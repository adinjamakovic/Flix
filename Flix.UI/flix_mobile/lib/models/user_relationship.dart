import 'package:json_annotation/json_annotation.dart';

part 'user_relationship.g.dart';

@JsonSerializable()
class UserRelationship {
  UserRelationship(
      this.userId,
      this.isSelf,
      this.isFollowing,
      this.isFollowedBy,
      this.isBlocked,
      this.isBlockedBy
      );

  final int? userId;
  final bool? isSelf;
  final bool? isFollowing;
  final bool? isFollowedBy;
  final bool? isBlocked;
  final bool? isBlockedBy;

  bool get following => isFollowing ?? false;
  bool get followedBy => isFollowedBy ?? false;
  bool get blocked => isBlocked ?? false;
  bool get blockedBy => isBlockedBy ?? false;

  bool get canFollow => !blocked && !blockedBy;

  // What the API calls a friend, and what the home feed's friend rows are built
  // from: the follow going both ways.
  bool get friends => following && followedBy;

  factory UserRelationship.fromJson(Map<String, dynamic> json) =>
      _$UserRelationshipFromJson(json);

  Map<String, dynamic> toJson() => _$UserRelationshipToJson(this);
}
