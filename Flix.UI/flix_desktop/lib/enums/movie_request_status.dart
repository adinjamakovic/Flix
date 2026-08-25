import 'package:json_annotation/json_annotation.dart';

enum MovieRequestStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  approved,
  @JsonValue(2)
  rejected
}

String getMovieRequestStatus(MovieRequestStatus status) {
  if (status == MovieRequestStatus.pending) {
    return "Pending";
  } else if (status == MovieRequestStatus.approved) {
    return "Approved";
  } else {
    return "Rejected";
  }
}
