import 'package:flutter/material.dart';

import 'package:trustme/core/utils/custom_colors.dart';

class AppTheme {
  ThemeData getAppTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      //region ## COLOR SCHEME - FROM SEED COLOR
      colorScheme: ColorScheme.fromSeed(
        seedColor: CustomColor.primaryColor,
        brightness: Brightness.light,

        primary: CustomColor.primaryColor,
        onPrimary: Colors.white,

        surface: CustomColor.colorLTSurface,
        onSurface: CustomColor.colorLTOnSurface,
        onSurfaceVariant: CustomColor.colorLTOnSurfaceVariant,

        error: CustomColor.vividRed,

        surfaceContainer: CustomColor.colorLTSurfaceContainer,

        secondaryContainer: CustomColor.colorLTSecondaryContainer,
        onSecondaryContainer: CustomColor.colorLTOnSecondaryContainer,

        surfaceContainerHigh: CustomColor.colorLTSurfaceContainerHigh,
        surfaceContainerHighest: CustomColor.colorLTSurfaceContainerHighest,

        outline: CustomColor.colorLTOutline,
        outlineVariant: CustomColor.colorLTOutlineVariant,
      ),
      //endregion

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CustomColor.primaryColor,
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
          backgroundColor: WidgetStatePropertyAll<Color>(CustomColor.primaryColor),
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
              return CustomColor.primaryColor;
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
            return CustomColor.primaryColor;
          }
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            if (states.contains(WidgetState.disabled)) {
              return CustomColor.primaryColor.withAlpha(120);
            } else {
              return CustomColor.primaryColor;
            }
          }

          if (states.contains(WidgetState.disabled)) {
            return Colors.black26;
          } else {
            return Colors.black54;
          }
        }),
      ),
      chipTheme: ChipThemeData(
        color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return CustomColor.primaryColor;
          } else {
            return CustomColor.primaryColor.withAlpha(20);
          }
        }),
        checkmarkColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CustomColor.primaryColor,
      )
    );
  }
}
