import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ontrack/common/controllers/home_controller.dart';
import 'package:ontrack/screens/home/widgets/banner_widget.dart';
import 'package:ontrack/screens/home/widgets/my_dot_navigation.dart';

class MyBannerSlider extends StatelessWidget {
  const MyBannerSlider({super.key});

  List<Map<String, dynamic>> getDummyBanners() {
    return [
      {
        'image': 'assets/banners/bn-1.jpg'
      }, // Replace with your dummy image paths
      {'image': 'assets/banners/bn-2.jpg'},
      {'image': 'assets/banners/bn-3.jpg'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final banners = getDummyBanners();

    return Column(
      children: [
        // Carousel Slider
        CarouselSlider(
          options: CarouselOptions(
            height: 125.h,
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
            autoPlay: true,
          ),
          items: banners.map((banner) {
            return MyBannerWidget(
                imageUrl: banner['image']); // Use your widget here
          }).toList(),
        ),
        SizedBox(height: 2),
        MyDotNavigation(controller: controller, dotCount: banners.length),
      ],
    );
  }
}
