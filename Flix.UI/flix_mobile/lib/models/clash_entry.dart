import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'clash_entry.g.dart';

@JsonSerializable()
class ClashEntry {
  ClashEntry(
    this.id,
    this.clashId,
    this.votes,
    this.isWinner,
    this.createdAt,
  );

  final int? id;
  final int? clashId;
  final int? votes;
  final bool? isWinner;
  final DateTime? createdAt;

  factory ClashEntry.fromJson(Map<String, dynamic> json) =>
      _$ClashEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ClashEntryToJson(this);
}
