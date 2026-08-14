import 'package:flix_mobile/models/cast_member.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class CastMemberProvider extends BaseProvider<CastMember> {
  CastMemberProvider() : super("CastMember");

  @override
  CastMember fromJson(data) {
    return CastMember.fromJson(data);
  }
}
