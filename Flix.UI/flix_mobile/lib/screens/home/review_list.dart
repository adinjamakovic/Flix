import 'package:flutter/material.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => debugPrint('TODO: Implement screen'),
        child: const Text('Reviews Tab'),
      ),
    );
  }
}
