import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'role.g.dart';

@JsonSerializable()
class Role {
  Role(
      this.id,
      this.name,
      this.description,
      this.isActive
      );

  final int? id;
  final String? name;
  final String? description;
  final bool? isActive;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
