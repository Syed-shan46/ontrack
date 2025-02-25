import 'package:flutter/material.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/text_theme.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.lightBackground,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.accentColor,
    error: AppColors.errorColor,
    surface: AppColors.lightBackground,
    onPrimary: Colors.white, // Text color on primary color
    onSecondary: Colors.white, // Text color on secondary color
    onError: Colors.white,
    onSurface: AppColors.lightTextColor,
  ),
  appBarTheme: const AppBarTheme(
    color: AppColors.lightBackground,
    iconTheme: IconThemeData(color: AppColors.darkBackground),
    titleTextStyle: TextStyle(
      color: AppColors.darkTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: textTheme.apply(
    bodyColor: AppColors.darkTextColor,
    displayColor: AppColors.darkTextColor,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.green,
    selectedItemColor: AppColors.primaryColor, // Selected item color
    unselectedItemColor: Colors.grey, // Unselected item color
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.darkBackground),
    ),
  ),
);
