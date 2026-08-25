import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/screens/lists/movie_issue_report_list.dart';
import 'package:flix_desktop/screens/lists/user_report_list.dart';
import 'package:flutter/material.dart';

class Issues extends StatefulWidget {
  const Issues({super.key});

  @override
  State<Issues> createState() => _IssuesState();
}

class _IssuesState extends State<Issues> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.issues,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
            child: _buildHeader(),
          ),
          const SizedBox(height: 20),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MovieIssueReportList(),
                UserReportList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Issues",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Review the movie issues and user reports your users have sent in",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: colors.onSurface,
        unselectedLabelColor: colors.onSurfaceVariant,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colors.outlineVariant,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: "Movie Issues"),
          Tab(text: "User Reports"),
        ],
      ),
    );
  }
}
