import 'package:flix_desktop/models/clash_entry.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class ClashEntryProvider extends BaseProvider<ClashEntry> {
  ClashEntryProvider() : super("ClashEntry");

  @override
  ClashEntry fromJson(data) {
    return ClashEntry.fromJson(data);
  }
}
