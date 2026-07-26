import 'package:flix_desktop/screens/movie_list.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
const LoginScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Card(

            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Padding(
            padding: EdgeInsets.all(16.0), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Text(
                    "FLIX", 
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold, 
                      fontSize: 40
                      ),
                    )
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Username"
                    ),
                  )
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Password"
                    ),
                  )
                ),
                ElevatedButton( 
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MovieList()));
                  },
                  child: Text("Login")
                ) 
              ],
            ),)
          ),
        ),
      ),
    );
  }
}