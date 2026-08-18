import 'package:json_annotation/json_annotation.dart';

enum ListType {
  @JsonValue(0)
  custom,
  @JsonValue(1)
  watchlist,
  @JsonValue(2)
  clash
}
