import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class Statistics extends StatefulWidget {
  const Statistics({ Key? key, }) : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Statistics",
      destination: DrawerDestination.statistics,
      child: Center(
        child: Container(
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("TODO: Add Auth and Statistics :)")),
        ),
      ), );
  }
}