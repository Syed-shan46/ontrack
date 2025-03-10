import 'package:flutter/material.dart';
import 'package:ontrack/screens/product_review/rating_bar_indicator.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';
import 'package:readmore/readmore.dart';

class MyUserReviewCard extends StatelessWidget {
  const MyUserReviewCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/restaurant.jpg')),
                const SizedBox(width: MySizes.spaceBtwItems),
                Text(
                  name,
                  style: TextStyle(
                      color: ThemeUtils.dynamicTextColor(context),
                      fontSize: 16),
                )
              ],
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ))
          ],
        ),

        const SizedBox(height: MySizes.spaceBtwItems),

        /// user review
        Row(
          children: [
            const MyRatingBarIndicator(rating: 4),
            const SizedBox(width: MySizes.spaceBtwItems),
            Text('02 Nov 2024', style: TextStyle(color: Colors.grey)),
          ],
        ),

        /// user description
        const SizedBox(height: MySizes.spaceBtwItems),
        ReadMoreText(
          "The food was absolutely wonderful, from preparation to presentation, very pleasing. We especially enjoyed the special bar drinks, the cucumber/cilantro infused vodka martini and the house-made ginger beer. The ambiance was perfect for a relaxing evening out.",
          trimLines: 2,
          trimExpandedText: ' show less',
          trimCollapsedText: ' show more',
          trimMode: TrimMode.Line,
          style: TextStyle(color: ThemeUtils.dynamicTextColor(context)),
          moreStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.accentColor),
          lessStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.accentColor),
        ),
        const SizedBox(height: MySizes.spaceBtwItems),

        /// company review
      ],
    );
  }
}
