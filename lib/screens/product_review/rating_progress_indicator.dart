import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

import 'progress_indicator_and_rating.dart';

class rating_progress_indicator extends StatelessWidget {
  const rating_progress_indicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '4.8',
            style: TextStyle(
              color: ThemeUtils.dynamicTextColor(context),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
