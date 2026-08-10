import 'package:json_annotation/json_annotation.dart';

part "language.g.dart";

@JsonSerializable()
class Language {
  Language(
    this.id,  
    this.name, 
    this.code);


  final int? id;
  final String? name;
  final String? code;

  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}