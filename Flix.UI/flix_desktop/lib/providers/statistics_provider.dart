import 'package:flix_desktop/models/admin_statistics.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class StatisticsProvider extends BaseProvider<AdminStatistics> {
  StatisticsProvider() : super("Statistics");

  Future<AdminStatistics> getStatistics() async {
    return AdminStatistics.fromJson(await getObject());
  }

  @override
  AdminStatistics fromJson(data) {
    return AdminStatistics.fromJson(data);
  }
}
