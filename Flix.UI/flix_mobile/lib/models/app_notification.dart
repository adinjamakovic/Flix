import 'package:flix_mobile/enums/notification_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_notification.g.dart';

@JsonSerializable()
class AppNotification {
  AppNotification(
    this.id,
    this.type,
    this.title,
    this.message,
    this.createdAt,
    this.readAt,
    this.isRead,
    this.movieRequestId,
    this.movieId,
  );

  final int? id;

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final NotificationType? type;

  final String? title;
  final String? message;

  final DateTime? createdAt;
  final DateTime? readAt;
  final bool? isRead;

  final int? movieRequestId;
  final int? movieId;

  bool get unread => isRead != true;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}
