import 'package:flutter/material.dart';
import 'package:ontrack/utils/themes/app_colors.dart';

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

    //textTheme: textTheme.apply(bodyColor: AppColors.lightTextColor),
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
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: AppColors.lightTextColor),
      hintStyle: TextStyle(color: AppColors.lightTextColor),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.lightTextColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
                AppColors.lightBackground.withOpacity(0.8)))));
