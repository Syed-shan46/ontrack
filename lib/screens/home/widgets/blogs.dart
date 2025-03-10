import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class Blogs extends StatelessWidget {
  const Blogs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySizes.spaceBtwItems),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                child: Image(
                  image: AssetImage('assets/images/restaurant.jpg'),
                  width: 120.w,
                  height: 90.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Blog description
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crossroads',
                style: TextStyle(color: Colors.blueGrey),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 180.w,
                child: Text(
                  'Food is more than just an experience, a story, and a journey. Whether you\'re a foodie searching for hidden gems or a casual diner looking for the next best meal,',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: ThemeUtils.dynamicTextColor(context),
                  ),
                ),
              ),
              SizedBox(height: 5),
              // Profile row
              Row(
                children: [
                  SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://picsum.photos/400/500?random=300')),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'John Doe',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  SizedBox(width: 6),
                  Text('.'),
                  SizedBox(width: 6),
                  Text(
                    'Feb 28,2025',
                    style: TextStyle(color: Colors.blueGrey),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
