import 'package:flix_mobile/models/studio.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class StudioProvider extends BaseProvider<Studio> {
  StudioProvider() : super("Studio");

  @override
  Studio fromJson(data) {
    return Studio.fromJson(data);
  }
}
