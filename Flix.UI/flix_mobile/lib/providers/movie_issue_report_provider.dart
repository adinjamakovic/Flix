import 'package:flix_mobile/enums/report_status.dart';
import 'package:flix_mobile/models/movie_issue_report.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class MovieIssueReportProvider extends BaseProvider<MovieIssueReport> {
  MovieIssueReportProvider() : super("MovieIssueReport");

  @override
  MovieIssueReport fromJson(data) {
    return MovieIssueReport.fromJson(data);
  }

  Future<SearchResult<MovieIssueReport>> getMyReports({
    ReportStatus? status,
    int page = 1,
    int pageSize = 10,
    bool includeMovie = true,
    bool includeReviewedBy = false,
    bool includeTotalCount = true,
  }) {
    return get(filter: {
      "page": page,
      "pageSize": pageSize,
      if (status != null) "status": status.index,
      "includeMovie": includeMovie,
      "includeReviewedBy": includeReviewedBy,
      "includeTotalCount": includeTotalCount,
    });
  }

  Future<MovieIssueReport> submitReport({
    required int movieId,
    required String header,
    String? description,
  }) {
    return insertJson({
      "movieId": movieId,
      "header": header,
      "description": description,
    });
  }

  Future<MovieIssueReport> editReport(
    int id, {
    required int movieId,
    required String header,
    String? description,
  }) {
    return updateJson(id, {
      "movieId": movieId,
      "header": header,
      "description": description,
    });
  }
}
