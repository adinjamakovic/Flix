import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({ super.key, });

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "User list",
      destination: DrawerDestination.users,
      child: Center(
        child: Container(
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("TODO: Add Auth and User List :)")),
        ),
      ), );
  }
}