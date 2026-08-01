import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({ super.key, });

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Review list",
      destination: DrawerDestination.reviews,
      child: Center(
        child: Container(
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("TODO: Add Auth and Review List :)")),
        ),
      ), );
  }
}