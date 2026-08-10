import 'package:flutter/material.dart';

class ClashList extends StatefulWidget {
  const ClashList({super.key});

  @override
  _ClashListState createState() => _ClashListState();
}

class _ClashListState extends State<ClashList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => debugPrint('TODO: Implement screen'),
        child: const Text('Clashes Tab'),
      ),
    );
  }
}
