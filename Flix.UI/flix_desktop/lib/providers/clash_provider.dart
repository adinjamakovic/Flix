import 'package:flix_desktop/models/clash.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class ClashProvider extends BaseProvider<Clash> {
  ClashProvider() : super("Clash");

  @override
  Clash fromJson(data) {
    return Clash.fromJson(data);
  }
}
