import 'package:flutter/material.dart';

class AddMovie extends StatelessWidget {
const AddMovie({ super.key });

  @override
  Widget build(BuildContext context){
    return Container(
      child: Center(
        child: ElevatedButton(onPressed: () => {print("TODO: Implement screen")}, child: Text("Add Movie Screen"))
      ),
    );
  }
}