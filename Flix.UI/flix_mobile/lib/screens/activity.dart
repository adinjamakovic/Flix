import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({ Key? key }) : super(key: key);

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(onPressed: () => {print("TODO: Implement screen")}, child: Text("Activity Screen"))
      ),
    );
  }
}