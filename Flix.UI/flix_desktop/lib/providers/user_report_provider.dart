import 'package:flix_desktop/enums/report_status.dart';
import 'package:flix_desktop/models/user_report.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class UserReportProvider extends BaseProvider<UserReport> {
  UserReportProvider() : super("UserReport");

  Future<UserReport> review(
    UserReport report, {
    required ReportStatus status,
    required String adminComment,
  }) async {
    return updateJson(report.id!, {
      "status": status.index,
      "adminComment": adminComment,
    });
  }

  @override
  UserReport fromJson(data) {
    return UserReport.fromJson(data);
  }
}
