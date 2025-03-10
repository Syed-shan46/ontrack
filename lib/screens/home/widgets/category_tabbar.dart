import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ontrack/screens/products/food_details_screen.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class CategoryTabbar extends StatelessWidget {
  const CategoryTabbar({
    super.key,
    required this.isDarkMode,
    required this.foods,
    required this.names,
  });

  final bool isDarkMode;
  final List<String> foods;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
            dragStartBehavior: DragStartBehavior.start,
            splashFactory: NoSplash.splashFactory,
            dividerColor: Colors.transparent,
            unselectedLabelStyle: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            isScrollable: true,
            labelStyle: TextStyle(
              color: ThemeUtils.dynamicTextColor(context),
              fontWeight: FontWeight.bold,
            ),
            indicator: DotIndicator(
              // Indicator
              color: AppColors.primaryColor,
              distanceFromCenter: 12,
              radius: 2.3,
            ),
            tabs: [
              Tab(
                text: 'Cakes',
              ),
              Tab(
                text: 'Rice',
              ),
              Tab(
                text: 'Burger',
              ),
              Tab(
                text: 'Pizza',
              ),
              Tab(
                text: 'Chicken',
              ),
              Tab(
                text: 'Drumstick',
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            height: 240.h,
            child: TabBarView(
              children: [
                // Cakes
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        key: PageStorageKey('live_items'),
                        itemCount: 3, // Number of items
                        clipBehavior: Clip.none,

                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => FoodDetailScreen());
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Restaurant Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/food0.jpg', // Sample image
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12), // Spacing

                                  // Restaurant Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Restaurant Name
                                        Text(
                                          names[index],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: ThemeUtils.dynamicTextColor(
                                                context),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        // Cuisine Type
                                        Text(
                                          "Breakfast • International • Sandwiches",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        SizedBox(height: 4),

                                        // Rating & Reviews
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.orange, size: 16),
                                            SizedBox(width: 4),
                                            Text("4.3",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                            SizedBox(width: 6),
                                            Text(
                                              "(108)",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Special offer",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 4),

                                        // Price & Time
                                        Row(
                                          children: [
                                            Text("₹ 200",
                                                style: TextStyle(
                                                    color: ThemeUtils
                                                        .dynamicTextColor(
                                                            context),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(width: 10),
                                            Icon(Icons.access_time,
                                                size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text("40 min",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ],
                                        ),

                                        SizedBox(height: 4),

                                        // Special Offer (if available)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                Center(child: Text("Rice Content")),
                Center(child: Text("Burger Content")),
                Center(child: Text("Pizza Content")),
                Center(child: Text("Chicken Content")),
                Center(child: Text("Drumstick Content")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
