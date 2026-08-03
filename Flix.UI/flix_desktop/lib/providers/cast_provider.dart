import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class CastProvider  extends BaseProvider<CastMember> {
  CastProvider() : super("CastMember");

  @override
  CastMember fromJson(data) {
    return CastMember.fromJson(data);
  }
}