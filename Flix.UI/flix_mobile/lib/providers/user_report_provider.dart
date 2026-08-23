import 'package:flix_mobile/enums/report_status.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/user_report.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class UserReportProvider extends BaseProvider<UserReport> {
  UserReportProvider() : super("UserReport");

  @override
  UserReport fromJson(data) {
    return UserReport.fromJson(data);
  }

  Future<SearchResult<UserReport>> getMyReports({
    ReportStatus? status,
    int page = 1,
    int pageSize = 10,
    bool includeReportedUser = true,
    bool includeReviewedBy = false,
    bool includeTotalCount = true,
  }) {
    return get(filter: {
      "page": page,
      "pageSize": pageSize,
      if (status != null) "status": status.index,
      "includeReportedUser": includeReportedUser,
      "includeReviewedBy": includeReviewedBy,
      "includeTotalCount": includeTotalCount,
    });
  }
}
