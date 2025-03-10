import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ontrack/utils/constants/sizes.dart';

class MyRatingBarIndicator extends StatelessWidget {
  const MyRatingBarIndicator({
    super.key,
    required this.rating,
  });

  final double rating;

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
        rating: rating,
        itemSize: MySizes.fontSizeMd.sp,
        unratedColor: Colors.grey,
        itemBuilder: (_, __) =>
            Icon(Iconsax.star1, color: Colors.yellow.withOpacity(0.8)));
  }
}
