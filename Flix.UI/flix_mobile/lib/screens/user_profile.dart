import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({ super.key });

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
   return Container(
      child: Center(
        child: ElevatedButton(onPressed: () => {print("TODO: Implement screen")}, child: Text("User Profile Screen"))
      ),
    );
  }
}