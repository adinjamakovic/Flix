import 'package:flix_mobile/models/country.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'user.g.dart';

@JsonSerializable()
class User {
  User(
      this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.username,
      this.role,
      this.roleId,
      this.isActive,
      this.createdAt,
      this.lastLoginAt,
      this.phoneNumber,
      this.profileImage,
      this.bio,
      this.moviesWatched,
      this.reviewsWritten,
      this.country,
      this.reviews
      );

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? username;
  final String? role;
  final int? roleId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? phoneNumber;
  // `UserResponse.ProfileImage` — a read-only SAS URL, not a blob path.
  final String? profileImage;
  final String? bio;
  final int? moviesWatched;
  final int? reviewsWritten;
  final Country? country;
  final List<Review>? reviews;

  String? get fullName {
    final List<String> parts = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();

    return parts.isEmpty ? null : parts.join(" ");
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
