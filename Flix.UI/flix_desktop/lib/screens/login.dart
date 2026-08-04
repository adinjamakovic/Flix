import 'package:flix_desktop/providers/auth_provider.dart';
import 'package:flix_desktop/screens/lists/movie_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({ super.key });

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username"
                    ),
                  )
                ),
                Container(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password"
                    ),
                  )
                ),
                ElevatedButton( 
                  onPressed: () async {

                    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
                    try{
                      await authProvider.login(_usernameController.text, _passwordController.text);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MovieList()));
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }

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