import 'package:flutter/material.dart';

class Dilogue {
  static void showsnabar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue.withOpacity(0.6),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showprogrssbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
