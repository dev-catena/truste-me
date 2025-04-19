import 'package:flutter/material.dart';

import 'utils/custom_colors.dart';

class AppTheme {
  ThemeData getAppTheme(BuildContext context) {
    return ThemeData(
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CustomColor.activeColor,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white); // Selected icon color
            }
            return const IconThemeData(color: Colors.black); // Unselected icon color
          },
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(CustomColor.activeColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll<Color>(CustomColor.vividRed),
          side: WidgetStateProperty.all(const BorderSide(color: CustomColor.vividRed)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
    );
  }
}
