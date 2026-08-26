import 'package:json_annotation/json_annotation.dart';

enum MovieRequestStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  approved,
  @JsonValue(2)
  rejected,
  @JsonValue(3)
  cancelled
}

String getMovieRequestStatus(MovieRequestStatus status)
{
  return switch (status) {
    MovieRequestStatus.pending => "Pending",
    MovieRequestStatus.approved => "Approved",
    MovieRequestStatus.rejected => "Rejected",
    MovieRequestStatus.cancelled => "Cancelled",
  };
}
