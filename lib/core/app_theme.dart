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
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return CustomColor.activeColor;
            }
            return null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.black54;
          }),

        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.black),
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return CustomColor.activeColor;
          }
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return CustomColor.activeColor;
          }
          return Colors.black54;
        }),
      ),
      chipTheme: ChipThemeData(
        color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return CustomColor.activeColor;
          } else {
            return CustomColor.activeColor.withAlpha(20);
          }
        }),
        checkmarkColor: Colors.white,
      ),
    );
  }
}
