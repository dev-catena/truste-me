import 'package:flutter/material.dart';
import 'package:trustme/core/global/global_variables.dart';

abstract class CustomColor {
  static const Color vividRed = Color.fromARGB(255, 224, 54, 54);
  static const Color successGreen = Color.fromARGB(255, 73, 189, 45);
  static const Color pendingYellow = Color.fromARGB(255, 210, 179, 65);

  //static const Color primaryColor = ;
  static const Color primaryColor = GlobalVariables.DEF_USE_LOGO_COLOR_AS_APP_COLOR ? Color(0xFF17355B) : Color.fromARGB(255, 16, 129, 203);

  //static const Color activeColor = Color.fromARGB(255, 16, 129, 203);
  static const Color activeColor = GlobalVariables.DEF_USE_LOGO_COLOR_AS_APP_COLOR ? const Color(0xFF17355B) : Color.fromARGB(255, 16, 129, 203);
  static const Color activeGreyed = Color.fromARGB(255, 118, 132, 138);
  static const Color bottomBarBg = Colors.white;

  static const Color backgroundPrimaryColor = Color.fromARGB(255, 245, 249, 255);

  static const colorLTSurface = const Color(0xFFFFFFFF);
  static const colorLTOnSurface = const Color(0xFF1a1b22);
  static const colorLTOnSurfaceVariant = const Color(0xFF444653);

  static const colorLTSurfaceContainer = const Color(0xFFebf0f6);
  static const colorLTSecondaryContainer = const Color(0xFFd7e2ed);
  static const colorLTOnSecondaryContainer = const Color(0xFF000000);

  static const colorLTSurfaceContainerHigh = const Color(0xFFd7e2ed);
  static const colorLTSurfaceContainerHighest = const Color(0xFFe2e1eb);
  static const colorLTOutline = const Color(0xFFb9bac1);
  static const colorLTOutlineVariant = const Color(0xFFe5e5e5);
}
