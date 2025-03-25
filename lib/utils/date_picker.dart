import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker(BuildContext context) async {
  return await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.green,
            onPrimary: Colors.white,
            surface: Colors.black,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Colors.black,
        ),
        child: child!,
      );
    },
  );
} 