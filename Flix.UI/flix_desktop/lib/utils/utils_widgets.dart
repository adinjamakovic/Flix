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

// Dates are shown as dd/mm/yyyy across every list screen.
String formatDate(DateTime? date) {
  if (date == null) return "-";
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  return "$day/$month/${date.year}";
}

// Whole ratings are shown without the redundant ".0" ("4", not "4.0").
String formatRating(double rating) {
  return rating == rating.roundToDouble()
      ? rating.toStringAsFixed(0)
      : rating.toStringAsFixed(1);
}

const String mField = "This field is mandatory";

const String numericField = "This field is numeric";

const String dateField = "This field is a date field";