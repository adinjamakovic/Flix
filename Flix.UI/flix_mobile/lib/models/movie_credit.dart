import 'package:flix_mobile/models/cast_member.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'movie_credit.g.dart';

@JsonSerializable()
class MovieCredit {
  MovieCredit(
      this.castMember,
      this.role,
      this.characterName,
      this.orderOfAppearence
      );

  final CastMember? castMember;
  final int? role;
  final String? characterName;
  final int? orderOfAppearence;

  String? get name => castMember?.fullName;

  /// "Sigourney Weaver as Ripley", falling back to the plain name.
  String? get nameWithCharacter {
    final String? memberName = name;

    if (memberName == null) return null;

    final String character = characterName?.trim() ?? "";

    return character.isEmpty ? memberName : "$memberName as $character";
  }

  factory MovieCredit.fromJson(Map<String, dynamic> json) =>
      _$MovieCreditFromJson(json);

  Map<String, dynamic> toJson() => _$MovieCreditToJson(this);
}
