import 'package:flutter/material.dart';

class AddMovie extends StatelessWidget {
const AddMovie({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      child: Center(
        child: ElevatedButton(onPressed: () => {print("TODO: Implement screen")}, child: Text("Add Movie Screen"))
      ),
    );
  }
}