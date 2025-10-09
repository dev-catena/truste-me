import 'package:flutter/material.dart';

import 'package:trustme/core/utils/custom_colors.dart';

extension SnackBarExtension on BuildContext {
  void showSnack(String message) {
    if(this.mounted) {
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)),);
    }
  }

  void showTopSnackBar(Widget child) {
    if(this.mounted) {
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        content: child,
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: CustomColor.vividRed.withRed(180),
        margin: EdgeInsets.only(
          bottom: MediaQuery
              .of(this)
              .size
              .height - 250,
          right: 20,
          left: 20,
        ),
      ));
    }
  }
}
