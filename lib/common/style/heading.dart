import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ontrack/common/style/app_style.dart';
import 'package:ontrack/common/style/reusable_text.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.title, this.ontap});

  final String title;
  final void Function()? ontap;

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
              if (ontap != null) {
                ontap!();
              }
            },
            icon: Icon(CupertinoIcons.arrow_right_circle,
                color: ThemeUtils.dynamicTextColor(context)),
          ),
        ],
      ),
    );
  }
}
