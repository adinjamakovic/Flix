import 'package:flix_mobile/enums/cast_role.dart';
import 'package:flix_mobile/models/country.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'cast_member.g.dart';

@JsonSerializable()
class CastMember {
  CastMember(
      this.id,
      this.firstName,
      this.lastName,
      this.country,
      this.birthDate,
      this.biography,
      this.photo,
      this.roles
      );

  final int? id;
  final String? firstName;
  final String? lastName;
  final Country? country;
  final DateTime? birthDate;
  final String? biography;
  final String? photo;
  final List<CastRole?>? roles;

  String? get fullName {
    final List<String> parts = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();

    return parts.isEmpty ? null : parts.join(" ");
  }

  factory CastMember.fromJson(Map<String, dynamic> json) =>
      _$CastMemberFromJson(json);

  Map<String, dynamic> toJson() => _$CastMemberToJson(this);
}
