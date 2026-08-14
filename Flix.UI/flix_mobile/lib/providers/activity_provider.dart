import 'package:flix_mobile/models/activity.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class ActivityProvider extends BaseProvider<Activity> {
  ActivityProvider() : super("Activity");

  @override
  Activity fromJson(data) {
    return Activity.fromJson(data);
  }

  Future<SearchResult<Activity>> getFromFollowers({
    int page = 1,
    int pageSize = 20,
  }) {
    return get(action: "FromFollowers", filter: _feedFilter(page, pageSize));
  }

  Future<SearchResult<Activity>> getFromSelf({
    int page = 1,
    int pageSize = 20,
  }) {
    return get(action: "FromSelf", filter: _feedFilter(page, pageSize));
  }

  Map<String, dynamic> _feedFilter(int page, int pageSize) => {
    "page": page,
    "pageSize": pageSize,
  };
}
