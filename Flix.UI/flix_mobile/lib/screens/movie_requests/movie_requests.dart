import 'package:flix_mobile/screens/movie_requests/add_movie.dart';
import 'package:flix_mobile/screens/movie_requests/movie_requests_list.dart';
import 'package:flix_mobile/widgets/notification_bell.dart';
import 'package:flutter/material.dart';

/// The "+" tab. The form is the tab itself, and the requests already sent hang
/// off the app bar.
class MovieRequests extends StatelessWidget {
  const MovieRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FLIX"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "My requests",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MovieRequestsList()),
            ),
          ),
          const NotificationBell(),
        ],
      ),
      body: const SafeArea(top: false, child: AddMovie()),
    );
  }
}
