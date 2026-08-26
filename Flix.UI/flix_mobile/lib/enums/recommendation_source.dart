import 'package:json_annotation/json_annotation.dart';

enum RecommendationSource {
  @JsonValue(0)
  similar,
  @JsonValue(1)
  popular
}
