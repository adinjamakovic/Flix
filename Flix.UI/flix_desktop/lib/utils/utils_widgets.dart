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

/// Blocks until the user answers, and returns true only if they confirmed.
/// Anything destructive goes through this first.
Future<bool> confirmBox(
  BuildContext context,
  String title,
  String content, {
  String confirmLabel = "Delete",
}) async {
  final ColorScheme colors = Theme.of(context).colorScheme;

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: colors.error),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  // Dismissing the dialog by tapping outside it is a "no".
  return confirmed ?? false;
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

const String emailField = "This field must be a valid email address";

const String phoneField = "This field must be a valid phone number";

// The validators below mirror the FluentValidation rules on the API so the form
// fails fast instead of round-tripping to get the same message back.

String? requiredValidator(String? value) {
  return (value == null || value.trim().isEmpty) ? mField : null;
}

String? maxLengthValidator(String? value, int maxLength) {
  return (value != null && value.trim().length > maxLength)
      ? "This field must be $maxLength characters or fewer"
      : null;
}

final RegExp _emailPattern =
    RegExp(r"^[\w.!#$%&'*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$");

String? emailValidator(String? value, {int maxLength = 150}) {
  final String email = value?.trim() ?? "";

  if (email.isEmpty) return mField;
  if (email.length > maxLength) return maxLengthValidator(email, maxLength);

  return _emailPattern.hasMatch(email) ? null : emailField;
}

// The API only caps the phone number's length, so the shape is enforced here:
// an optional leading "+", then digits with spaces, dashes, dots or brackets
// as separators.
final RegExp _phonePattern = RegExp(r"^\+?[\d\s().-]+$");

String? phoneValidator(String? value, {int maxLength = 25}) {
  final String phone = value?.trim() ?? "";

  if (phone.isEmpty) return null;
  if (phone.length > maxLength) return maxLengthValidator(phone, maxLength);
  if (!_phonePattern.hasMatch(phone)) return phoneField;

  final int digits = phone.replaceAll(RegExp(r"\D"), "").length;

  return (digits < 6 || digits > 15) ? phoneField : null;
}

// Same pattern and same messages as `UserInsertRequestValidator`.
final RegExp _passwordPattern =
    RegExp(r"(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])");

String? passwordValidator(String? value, {bool required = true}) {
  final String password = value ?? "";

  if (password.isEmpty) return required ? "Password is required." : null;
  if (password.length < 8) return "Password must be at least 8 characters.";
  if (!_passwordPattern.hasMatch(password)) {
    return "Password must contain upper, lower, a digit, and a special character.";
  }

  return null;
}