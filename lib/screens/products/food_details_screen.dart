import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ontrack/common/style/heading.dart';
import 'package:ontrack/screens/product_review/product_review.dart';
import 'package:ontrack/screens/product_review/rating_bar_indicator.dart';
import 'package:ontrack/screens/product_review/user_review_card.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';
import 'package:readmore/readmore.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final List<Map<String, dynamic>> reviews = [
    {
      "name": "Sophia Carter",
      "review":
          "Absolutely delicious! Perfectly cooked noodles with great flavors.",
      "rating": 5,
      "image": "assets/images/restaurant.jpg"
    },
    {
      "name": "Michael Smith",
      "review": "The noodles were great, but a bit too spicy for my taste.",
      "rating": 4,
      "image": "assets/images/restaurant.jpg"
    }
  ];

  double userRating = 0;

  TextEditingController reviewController = TextEditingController();

  void addReview() {
    if (reviewController.text.isNotEmpty && userRating > 0) {
      setState(() {
        reviews.insert(0, {
          "name": "You",
          "review": reviewController.text,
          "rating": userRating.toInt(),
          "image": "assets/images/restaurant.jpg"
        });
        reviewController.clear();
        userRating = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Image.asset(
                  'assets/images/food2.jpg', // Replace with actual image
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back, color: Colors.white)),
                  ),
                ),
              ],
            ),

            // Food Details Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Biriyani",
                        style: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹ 200",
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Chinese Cuisine",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  SizedBox(height: 10),
                  ReadMoreText(
                    trimExpandedText: 'show less',
                    trimCollapsedText: 'show more',
                    trimMode: TrimMode.Line,
                    trimLines: 2,
                    "Chilli Hakka noodles is a Chinese preparation where boiled noodles are stir-fried with sauces and vegetables or meats.",
                    style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.dynamicTextColor(context)
                            .withAlpha(MySizes.alphaHigh)),
                  ),
                  SizedBox(height: 5),

                  Divider(
                    height: 30,
                    color: Colors.grey.shade300,
                    thickness: 0,
                  ),

                  // Cooked by Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            AssetImage("assets/images/restaurant.jpg"),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cooked by",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            "Alicia Brown",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: ThemeUtils.dynamicTextColor(context)),
                          ),
                          MyRatingBarIndicator(rating: 4.5),
                        ],
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("View Profile",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  Divider(
                      height: 20, color: Colors.grey.shade300, thickness: 0),
                ],
              ),
            ),

            // Reviews Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Heading(
                title: 'Reviews',
                ontap: () {
                  Get.to(() => ProductReviewSceen());
                },
              ),
            ),

            // User Reviews List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MySizes.md),
              child: MyUserReviewCard(name: 'syed_shan'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MySizes.md),
              child: MyUserReviewCard(name: 'zayn_malik'),
            )
          ],
        ),
      ),
    );
  }
}

// Widget for User Reviews
class ReviewTile extends StatelessWidget {
  final String name;
  final String review;
  final int rating;
  final String image;

  const ReviewTile(
      {super.key,
      required this.name,
      required this.review,
      required this.rating,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(image)),
      title: Text(name,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeUtils.dynamicTextColor(context))),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              children: List.generate(rating,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 16))),
          Text(review,
              style: TextStyle(
                  color: ThemeUtils.dynamicTextColor(context).withAlpha(150))),
        ],
      ),
    );
  }
}
