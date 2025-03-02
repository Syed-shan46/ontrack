// MyBannerWidget
import 'package:flutter/material.dart';
import 'package:ontrack/common/shimmer/banner_shimmer.dart';

class MyBannerWidget extends StatefulWidget {
  const MyBannerWidget({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<MyBannerWidget> createState() => _MyBannerWidgetState();
}

class _MyBannerWidgetState extends State<MyBannerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 9, right: 9, bottom: 9),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            widget.imageUrl,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text('Error loading image'), // Handle image load errors
              );
            },
          ),
        ),
      ),
    );
  }
}
