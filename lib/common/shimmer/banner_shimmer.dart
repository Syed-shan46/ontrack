import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ontrack/common/shimmer/shimmer_widget.dart';

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: Column(
        children: [
          ShimmerWidget(
              shimmerWidth: double.infinity.h,
              shimmerHeight: 130.h,
              shimmerRadius: 12),
        ],
      ),
    );
  }
}
