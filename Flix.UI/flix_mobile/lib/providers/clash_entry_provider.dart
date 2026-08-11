import 'package:flix_mobile/models/clash_entry.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class ClashEntryProvider extends BaseProvider<ClashEntry> {
  ClashEntryProvider() : super("ClashEntry");

  @override
  ClashEntry fromJson(data) {
    return ClashEntry.fromJson(data);
  }
}
