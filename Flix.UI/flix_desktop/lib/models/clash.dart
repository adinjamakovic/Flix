import 'package:flix_desktop/enums/clash_status.dart';
import 'package:json_annotation/json_annotation.dart';

part "clash.g.dart";

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
    this.createdAt
  );
  
  
  final int? id;
  final String? name;
  final String? description;
  final ClashStatus? status;
  final int? participants;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  factory Clash.fromJson(Map<String, dynamic> json) => _$ClashFromJson(json);

  Map<String, dynamic> toJson() => _$ClashToJson(this);
}