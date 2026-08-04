import 'package:json_annotation/json_annotation.dart';

enum ClashStatus {
  @JsonValue(0)
  upcoming,
  @JsonValue(1)
  active,
  @JsonValue(2)
  completed
}

String getClashStatus(ClashStatus status) {
  if(status == ClashStatus.upcoming){
    return "Upcoming";
  } else if (status == ClashStatus.active) {
    return "Active";
  } else {
    return "Completed";
  }
}