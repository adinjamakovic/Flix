import 'package:flix_mobile/enums/clash_status.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'clash.g.dart';

@JsonSerializable()
class Clash {
  Clash(
    this.id,
    this.name,
    this.description,
    this.status,
    this.participants,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.bannerImage,
  );

  final int? id;
  final String? name;
  final String? description;
  final ClashStatus? status;
  final int? participants;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final String? bannerImage;

  factory Clash.fromJson(Map<String, dynamic> json) => _$ClashFromJson(json);

  Map<String, dynamic> toJson() => _$ClashToJson(this);
}
