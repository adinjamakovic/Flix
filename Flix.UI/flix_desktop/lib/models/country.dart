import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  Country(
     this.id,
     this.name, 
     this.code, 
     this.flagImageBase64
    );
  
  final int? id;
  final String? name;
  final String? code;
  final String? flagImageBase64;

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}