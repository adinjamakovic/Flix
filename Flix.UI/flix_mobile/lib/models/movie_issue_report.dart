import 'package:flix_mobile/enums/report_status.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_issue_report.g.dart';

@JsonSerializable()
class MovieIssueReport {
  MovieIssueReport(
    this.id,
    this.movieId,
    this.header,
    this.description,
    this.status,
    this.createdAt,
    this.reportedBy,
    this.movie,
    this.reviewedBy,
    this.resolvedAt,
    this.adminComment,
  );

  final int? id;
  final int? movieId;

  final String? header;
  final String? description;

  final ReportStatus? status;
  final DateTime? createdAt;

  final User? reportedBy;
  final Movie? movie;
  final User? reviewedBy;

  final DateTime? resolvedAt;
  final String? adminComment;

  String? get statusLabel => status == null ? null : getReportStatus(status!);

  factory MovieIssueReport.fromJson(Map<String, dynamic> json) =>
      _$MovieIssueReportFromJson(json);

  Map<String, dynamic> toJson() => _$MovieIssueReportToJson(this);
}
