// Defining a custom text theme

import 'package:flutter/material.dart';



TextTheme textTheme = const TextTheme(
  displayLarge: TextStyle(fontSize: 96.0, fontWeight: FontWeight.bold, letterSpacing: -1.5),
  displayMedium: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold, letterSpacing: -0.5),
  displaySmall: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 34.0, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
  titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 0.15),
  titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 1.25),
  bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w400, letterSpacing: 1.5),
);
