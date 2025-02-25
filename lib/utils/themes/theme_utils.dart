import 'package:flutter/material.dart';
import 'package:ontrack/utils/themes/app_colors.dart';

class ThemeUtils {
  static Color dynamicTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.darkBackground;
  }

  static Color sameBrightness(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBackground
        : Colors.white;
  }
}

class Navbg {
  static Color navbarBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 29, 29, 29)
        : Colors.white;
  }
}
