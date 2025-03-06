import 'package:flutter/material.dart';

import 'circular_container.dart';
import 'curved_edges_widget.dart';

class MyPrimaryHeaderContainer extends StatelessWidget {
  const MyPrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height = 170,
    this.showContainer = true,
  });

  final Widget child;
  final double? height;
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    return MyCurvedWidget(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: height,
            padding: const EdgeInsets.all(0),
            child: Image.asset(
              'assets/images/restaurant.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
