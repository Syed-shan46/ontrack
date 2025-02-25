import 'package:flutter/material.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/text_theme.dart';

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
      surface: AppColors.darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onError: Colors.white,
      onSurface: AppColors.darkTextColor,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.darkBackground,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: textTheme.apply(bodyColor: AppColors.lightTextColor),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      // Use primary color for dark theme
      selectedItemColor: AppColors.primaryColor, // Selected item color
      unselectedItemColor: Colors.grey, // Unselected item color
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
                AppColors.lightBackground.withOpacity(0.8)))));
