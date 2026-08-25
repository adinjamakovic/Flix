import 'package:json_annotation/json_annotation.dart';

part 'studio.g.dart';

@JsonSerializable()
class Studio {
  Studio(
      this.id,
      this.name,
      this.description,
      this.logo
      );

  final int? id;
  final String? name;
  final String? description;
  final String? logo;

  factory Studio.fromJson(Map<String, dynamic> json) => _$StudioFromJson(json);

  Map<String, dynamic> toJson() => _$StudioToJson(this);
}
