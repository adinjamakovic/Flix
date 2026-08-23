import 'package:flix_mobile/enums/report_status.dart';
import 'package:flix_mobile/layouts/profile_screen.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/models/user_report.dart';
import 'package:flix_mobile/providers/user_report_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyUserReports extends StatefulWidget {
  const MyUserReports({super.key});

  @override
  State<MyUserReports> createState() => _MyUserReportsState();
}

class _MyUserReportsState extends State<MyUserReports> {
  static const int _pageSize = 50;

  static const Color _resolvedColor = Color(0xFF22C55E);
  static const Color _openColor = Color(0xFFF59E0B);

  static const double _avatarRadius = 26;

  static const double _cardAccentWidth = 3;

  late UserReportProvider _reportProvider;

  List<UserReport> _reports = const [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _reportProvider = context.read<UserReportProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final SearchResult<UserReport> result = await _reportProvider
          .getMyReports(pageSize: _pageSize, includeReviewedBy: true);

      if (!mounted) return;

      setState(() {
        _reports = itemsOf(result);
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  void _openProfile(User? user) {
    if (user?.id == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: user!.id)),
    );
  }

  Color _statusColor(ReportStatus? status) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    switch (status) {
      case ReportStatus.resolved:
        return _resolvedColor;
      case ReportStatus.dismissed:
        return colors.error;
      case ReportStatus.open:
      case null:
        return _openColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My user reports")),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    if (_reports.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          // Nothing here fills the screen, and a list that cannot be dragged
          // cannot be pulled to refresh either.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            buildMessage(
              context,
              "You haven't reported anyone yet.\n"
              "Anything you send about another account shows up here.",
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        itemCount: _reports.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildReportCard(_reports[index]),
      ),
    );
  }

  Widget _buildReportCard(UserReport report) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color accent = _statusColor(report.status);

    final User? user = report.reportedUser;
    final String? description = report.description;
    final String? adminComment = report.adminComment;

    return Container(
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.only(left: _cardAccentWidth),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(4),
            right: Radius.circular(14),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _openProfile(user),
                  child: buildAvatar(
                    context,
                    user?.profileImage,
                    user?.username,
                    radius: _avatarRadius,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _openProfile(user),
                        child: Text(
                          user?.username ?? "-",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.header ?? "-",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Reported: ${formatDate(report.createdAt)}",
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildStatusBadge(report.status),
              ],
            ),
            if (description != null && description.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(color: colors.onSurface, fontSize: 13),
              ),
            ],
            if (adminComment != null && adminComment.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin reply",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adminComment,
                      style: TextStyle(color: colors.onSurface, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus? status) {
    final Color accent = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getReportStatus(status ?? ReportStatus.open),
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
