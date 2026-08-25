import 'package:flix_desktop/models/studio.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class StudioProvider extends BaseProvider<Studio> {
  StudioProvider() : super("Studio");

  @override
  Studio fromJson(data) {
    return Studio.fromJson(data);
  }
}
