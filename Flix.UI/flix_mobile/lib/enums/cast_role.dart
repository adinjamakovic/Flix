import 'package:json_annotation/json_annotation.dart';

/// Values mirror the backend `Flix.Model.Enums.CastRole`, which serializes as
/// its numeric value rather than the member name.
enum CastRole {
  @JsonValue(0)
  actor,
  @JsonValue(1)
  director
}

String getRoleName(CastRole role) {
  if(role == CastRole.actor){
    return "Actor";
  }
  else {
    return "Director";
  }
}
