import 'package:flix_mobile/screens/activity.dart';
import 'package:flix_mobile/screens/add_movie.dart';
import 'package:flix_mobile/layouts/home_screen.dart';
import 'package:flix_mobile/screens/search.dart';
import 'package:flix_mobile/screens/user_profile.dart';
import 'package:flutter/material.dart';

class ContainerScreen extends StatefulWidget {
  const ContainerScreen({ Key? key }) : super(key: key);

  @override
  _ContainerScreenState createState() => _ContainerScreenState();
}

class _ContainerScreenState extends State<ContainerScreen> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
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
      body: <Widget>[
        HomeScreen(),
        Search(),
        AddMovie(),
        Activity(),
        UserProfile(),
        ][currentPageIndex],
    );
  }
}