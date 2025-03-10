import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:ontrack/utils/helpers/box_decoration_helper.dart';
import 'package:ontrack/utils/themes/app_colors.dart';

class TrendingHotels extends StatelessWidget {
  const TrendingHotels({
    super.key,
    required this.names,
  });

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        key: PageStorageKey('live_items'),
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of live items
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: 15.w,
              right: index == 4 ? 15.w : 0,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: 90.w,
                      height: 80.h,
                      decoration: getDynamicBoxDecoration(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Stack(
                          children: [
                            // Item Image
                            Image.asset(
                              'assets/images/r$index.jpg',
                              fit: BoxFit.cover,
                              width: 90.w,
                              height: 80.h,
                            ), // Item Name Overlay

                            Positioned(
                              top: -15,
                              child: SizedBox(
                                height: 80.h,
                                width: 80.w,
                                child: Lottie.asset(
                                  'assets/animation/closed.json',
                                  width: 80.w,
                                  height: 80.h,
                                  onLoaded: (composition) {
                                    print('Lottie animation loaded');
                                  },
                                  errorBuilder: (context, object, stacktrace) {
                                    print('Lottie animation error: $object');
                                    return const Text("Lottie Error");
                                  },
                                ),
                              ),
                            ),

                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 100.w,
                                color: Colors.black54,
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 5.w),
                                child: Text(
                                  names[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    // Follow button
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.07,
                          vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 10.sp,
                          ),
                          Text('Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                // Add Button

                // Rating Badge
                Positioned(
                  top: 5.h,
                  left: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          color: Colors.white,
                          Icons.star,
                          size: 10.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '4.${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
