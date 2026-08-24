import 'package:flix_desktop/enums/report_status.dart';
import 'package:flix_desktop/models/movie_issue_report.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class MovieIssueReportProvider extends BaseProvider<MovieIssueReport> {
  MovieIssueReportProvider() : super("MovieIssueReport");

  Future<MovieIssueReport> review(
    MovieIssueReport report, {
    required ReportStatus status,
    required String adminComment,
  }) async {
    return updateJson(report.id!, {
      "movieId": report.movieId,
      "header": report.header,
      "description": report.description,
      "status": status.index,
      "adminComment": adminComment,
    });
  }

  @override
  MovieIssueReport fromJson(data) {
    return MovieIssueReport.fromJson(data);
  }
}
