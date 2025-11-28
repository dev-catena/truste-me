import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:trustme/core/utils/custom_colors.dart';

extension SnackBarExtension on BuildContext {
  void showSnack(String message) {
    if(this.mounted) {
      ScaffoldMessenger.of(this)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message), action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(this).hideCurrentSnackBar()),),);
    }
  }

  // Deprecated, use showTopFlushbar instead
  void showTopSnackBar(Widget child) {
    if(this.mounted) {
      ScaffoldMessenger.of(this)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
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

  void showTopFlushbar(Widget child, String title) {
    if(this.mounted) {
      Flushbar(
        title: title,
        messageText: child,
        backgroundColor: CustomColor.vividRed.withRed(180),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        borderRadius: BorderRadius.circular(8),
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        margin: EdgeInsets.all(24),
        duration: Duration(seconds: 20),
      )..show(this);
    }
  }
}
