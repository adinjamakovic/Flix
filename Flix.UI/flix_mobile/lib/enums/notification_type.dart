import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

enum NotificationType {
  @JsonValue(0)
  movieRequestSubmitted,
  @JsonValue(1)
  movieRequestReceived,
  @JsonValue(2)
  movieRequestApproved,
  @JsonValue(3)
  movieRequestRejected,
  @JsonValue(4)
  movieRequestCancelled,
  @JsonValue(5)
  movieIssueReportReviewed,
  @JsonValue(6)
  userReportReviewed,
}

IconData getNotificationIcon(NotificationType type) {
  return switch (type) {
    NotificationType.movieRequestSubmitted => Icons.send_outlined,
    NotificationType.movieRequestReceived => Icons.inbox_outlined,
    NotificationType.movieRequestApproved => Icons.check_circle_outline,
    NotificationType.movieRequestRejected => Icons.cancel_outlined,
    NotificationType.movieRequestCancelled => Icons.undo_outlined,
    NotificationType.movieIssueReportReviewed => Icons.flag_outlined,
    NotificationType.userReportReviewed => Icons.gavel_outlined,
  };
}
