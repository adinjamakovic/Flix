import 'package:flix_mobile/enums/report_status.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_report.g.dart';

@JsonSerializable()
class UserReport {
  UserReport(
    this.id,
    this.reportedUserId,
    this.header,
    this.description,
    this.status,
    this.createdAt,
    this.reporter,
    this.reportedUser,
    this.reviewedBy,
    this.resolvedAt,
    this.adminComment,
  );

  final int? id;
  final int? reportedUserId;

  final String? header;
  final String? description;

  final ReportStatus? status;
  final DateTime? createdAt;

  final User? reporter;
  final User? reportedUser;
  final User? reviewedBy;

  final DateTime? resolvedAt;
  final String? adminComment;

  String? get statusLabel => status == null ? null : getReportStatus(status!);

  factory UserReport.fromJson(Map<String, dynamic> json) =>
      _$UserReportFromJson(json);

  Map<String, dynamic> toJson() => _$UserReportToJson(this);
}
