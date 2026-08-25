import 'package:flix_desktop/enums/report_status.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/models/user_report.dart';
import 'package:flix_desktop/providers/user_report_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flix_desktop/widgets/report_card.dart';
import 'package:flix_desktop/widgets/report_review_dialog.dart';
import 'package:flix_desktop/widgets/report_status_filter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserReportList extends StatefulWidget {
  const UserReportList({super.key});

  @override
  State<UserReportList> createState() => _UserReportListState();
}

class _UserReportListState extends State<UserReportList> {
  static const int _pageSize = 5;

  late UserReportProvider _reportProvider;

  SearchResult<UserReport>? result;
  bool isLoading = true;
  int _page = 1;

  ReportStatus? _status = ReportStatus.open;

  @override
  void initState() {
    super.initState();

    _reportProvider = context.read<UserReportProvider>();

    _search(page: 1);
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeReporter": true,
      "includeReportedUser": true,
      "includeReviewedBy": true,
    };

    final ReportStatus? status = _status;
    if (status != null) {
      filter["status"] = status.index;
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _reportProvider.get(filter: _buildFilter(requestedPage));

      if (!mounted) return;

      setState(() {
        result = data;
        _page = requestedPage;
        isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _review(UserReport report) async {
    final int? id = report.id;
    if (id == null) return;

    final ReportReview? review = await showReportReviewDialog(
      context,
      header: report.header ?? "-",
      status: report.status ?? ReportStatus.open,
      adminComment: report.adminComment,
    );

    if (review == null || !mounted) return;

    try {
      await _reportProvider.review(
        report,
        status: review.status,
        adminComment: review.adminComment,
      );
    } on Exception catch (e) {
      if (!mounted) return;

      alertBox(context, "Error", e.toString());
      return;
    }

    if (!mounted) return;

    final bool wasLastOnPage = (result?.items?.length ?? 0) == 1 && _page > 1;

    await _search(page: wasLastOnPage ? _page - 1 : _page);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportStatusFilter(
            status: _status,
            allLabel: "All reports",
            onChanged: (status) {
              setState(() {
                _status = status;
              });
              _search(page: 1);
            },
          ),
          const SizedBox(height: 22),
          Expanded(child: _buildList()),
          const SizedBox(height: 12),
          Pagination(
            page: _page,
            pageSize: _pageSize,
            totalCount: result?.totalCount ?? 0,
            onPageChanged: (page) => _search(page: page),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<UserReport> reports = result?.items ?? List.empty();

    if (reports.isEmpty) {
      return Center(
        child: Text(
          "No user reports found",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildCard(reports[index]),
    );
  }

  Widget _buildCard(UserReport report) {
    return ReportCard(
      header: report.header ?? "-",
      subjectIcon: Icons.person_outline,
      subject: _reportedUser(report),
      reportedBy: report.reporter?.username ?? "-",
      createdAt: report.createdAt,
      description: report.description,
      status: report.status ?? ReportStatus.open,
      reviewedBy: report.reviewedBy?.username,
      resolvedAt: report.resolvedAt,
      adminComment: report.adminComment,
      onReview: () => _review(report),
    );
  }

  String _reportedUser(UserReport report) {
    final String username = report.reportedUser?.username ?? "Unknown user";
    final String? fullName = report.reportedUser?.fullName;

    return fullName == null ? username : "$username ($fullName)";
  }
}
