import 'package:flix_mobile/layouts/profile_screen.dart';
import 'package:flix_mobile/screens/activity.dart';
import 'package:flix_mobile/layouts/home_screen.dart';
import 'package:flix_mobile/providers/notification_provider.dart';
import 'package:flix_mobile/screens/movie_requests/movie_requests.dart';
import 'package:flix_mobile/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ContainerScreen extends StatefulWidget {
  const ContainerScreen({ super.key });

  @override
  _ContainerScreenState createState() => _ContainerScreenState();
}

class _ContainerScreenState extends State<ContainerScreen> {
  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    Search(),
    MovieRequests(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    _tabs.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  final Set<int> _openedTabs = <int>{0};

  int currentPageIndex = 0;

  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    super.initState();

    _notificationProvider = context.read<NotificationProvider>();

    _notificationProvider.start();
  }

  @override
  void dispose() {
    _notificationProvider.stop();

    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == currentPageIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _openedTabs.add(index);
      currentPageIndex = index;
    });
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;

    final NavigatorState? navigator =
        _navigatorKeys[currentPageIndex].currentState;

    if (navigator != null && await navigator.maybePop()) return;

    if (currentPageIndex != 0) {
      setState(() => currentPageIndex = 0);
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: _onDestinationSelected,
          indicatorColor: theme.colorScheme.primary,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.movie_filter_outlined),
              icon: Icon(Icons.movie_filter_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.search),
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.add_circle_outline),
              icon:  Icon(Icons.add_circle_outline, color: Colors.red,),
              label: 'Add Movie',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.monitor_heart_outlined),
              icon:  Icon(Icons.monitor_heart_outlined),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              label: 'User Profile',
            ),
          ],
        ),
        body: IndexedStack(
          index: currentPageIndex,
          children: <Widget>[
            for (int index = 0; index < _tabs.length; index++)
              _openedTabs.contains(index)
                  ? _buildTabNavigator(index)
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (context) => _tabs[index],
      ),
    );
  }
}
