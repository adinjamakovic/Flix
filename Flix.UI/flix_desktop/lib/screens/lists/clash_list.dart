import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class ClashList extends StatefulWidget {
  const ClashList({ super.key, });

  @override
  _ClashListState createState() => _ClashListState();
}

class _ClashListState extends State<ClashList> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Clash list",
      destination: DrawerDestination.clashes,
      child: Center(
        child: Container(
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("TODO: Add Auth and Clash List :)")),
        ),
      ), );
  }
}