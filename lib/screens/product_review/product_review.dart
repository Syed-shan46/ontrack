import 'package:flutter/material.dart';
import 'package:ontrack/screens/product_review/user_review_card.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

import '../../../../utils/constants/sizes.dart';
import 'rating_bar_indicator.dart';
import 'rating_progress_indicator.dart';

class ProductReviewSceen extends StatelessWidget {
  const ProductReviewSceen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// appbar
      appBar: AppBar(
        title: const Text('Product Review'),
        centerTitle: true,
      ),

      /// body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// overall product rating
              const rating_progress_indicator(),
              const MyRatingBarIndicator(rating: 3.8),
              Text('12,611',
                  style:
                      TextStyle(color: ThemeUtils.dynamicTextColor(context))),
              const SizedBox(height: MySizes.spaceBtwSections),

              /// user review list
              const MyUserReviewCard(
                name: 'Some one',
              ),
              const SizedBox(height: 20),
              const MyUserReviewCard(
                name: 'John doe',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
