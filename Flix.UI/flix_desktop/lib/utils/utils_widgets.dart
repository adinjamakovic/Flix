import 'package:flutter/material.dart';

void alertBox(BuildContext context, String title, String content) {
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: Text("OK"))
      ],
    ));
}

const String mField = "This field is mandatory";

const String numericField = "This field is numeric";

const String dateField = "This field is a date field";