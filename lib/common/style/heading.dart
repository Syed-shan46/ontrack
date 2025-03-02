import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ontrack/common/style/app_style.dart';
import 'package:ontrack/common/style/reusable_text.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // title
          ReusableText(
            text: title,
            style: appStyle(
              17,
              ThemeUtils.dynamicTextColor(context).withOpacity(0.9),
              FontWeight.w600,
            ),
          ),
          // IconButton
          IconButton(
            onPressed: () {
              Get.snackbar(
                'More',
                'More options will be available soon',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: ThemeUtils.dynamicTextColor(context),
                colorText: ThemeUtils.dynamicTextColor(context),
                margin: EdgeInsets.only(bottom: 20.h),
              );
            },
            icon: Icon(CupertinoIcons.arrow_right_circle,
                color: ThemeUtils.dynamicTextColor(context)),
          ),
        ],
      ),
    );
  }
}
