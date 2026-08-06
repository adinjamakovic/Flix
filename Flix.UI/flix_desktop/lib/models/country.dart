import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  Country(
     this.id,
     this.name, 
     this.code, 
     this.flagImage
    );

  final int? id;
  final String? name;
  final String? code;
  // `CountryResponse.FlagImage` — the stored blob path/URL, not base64.
  final String? flagImage;

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}