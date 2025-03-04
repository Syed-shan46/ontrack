import 'package:flutter/material.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;

  const MyTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: ThemeUtils.dynamicTextColor(context),
      ),
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: ThemeUtils.dynamicTextColor(context),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey)),
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
      ),
    );
  }
}
