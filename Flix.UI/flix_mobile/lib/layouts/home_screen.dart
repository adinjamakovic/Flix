import 'package:flix_mobile/screens/home/clash_list.dart';
import 'package:flix_mobile/screens/home/movie_list.dart';
import 'package:flix_mobile/screens/home/review_list.dart';
import 'package:flutter/material.dart';

/// The "FLIX" wordmark header plus the tab bar that switches between the
/// movie, review and clash feeds.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tabs = <String>['Movies', 'Reviews', 'Clashes'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FLIX'),
          bottom: TabBar(
            tabs: _tabs.map((label) => Tab(text: label)).toList(),
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            MovieList(),
            ReviewList(),
            ClashList(),
          ],
        ),
      ),
    );
  }
}
