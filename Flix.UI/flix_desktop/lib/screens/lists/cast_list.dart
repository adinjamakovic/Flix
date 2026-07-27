import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class CastList extends StatefulWidget {
  const CastList({ super.key, });

  @override
  _CastListState createState() => _CastListState();
}

class _CastListState extends State<CastList> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Cast list",
      destination: DrawerDestination.cast,
      child: Center(
        child: Container(
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("TODO: Add Auth and Cast List :)")),
        ),
      ), );
  }
}