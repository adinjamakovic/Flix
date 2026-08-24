import 'package:json_annotation/json_annotation.dart';

enum ReportStatus {
  @JsonValue(0)
  open,
  @JsonValue(1)
  resolved,
  @JsonValue(2)
  dismissed
}

String getReportStatus(ReportStatus status) {
  if (status == ReportStatus.open) {
    return "Open";
  } else if (status == ReportStatus.resolved) {
    return "Resolved";
  } else {
    return "Dismissed";
  }
}
