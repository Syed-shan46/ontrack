import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ontrack/common/style/app_style.dart';
import 'package:ontrack/common/style/reusable_text.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
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
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/more-7.svg',
              height: 23,
              color: AppColors.primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
