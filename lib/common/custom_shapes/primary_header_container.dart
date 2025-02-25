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
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.blue.shade700,
              Colors.blue.shade600,
            ],
          ),
        ),
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            showContainer
                ? Positioned(
                    top: -70,
                    right: -70,
                    child: MyCircularContainer(
                      width: 205,
                      height: 205,
                      radius: 400,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  )
                : const SizedBox(
                    height: null,
                  ),
            showContainer
                ? Positioned(
                    top: -70,
                    right: -25,
                    child: MyCircularContainer(
                        width: 205,
                        height: 205,
                        radius: 400,
                        backgroundColor: Colors.white.withOpacity(0.1)),
                  )
                : const SizedBox(
                    height: null,
                  ),
            child,
          ],
        ),
      ),
    );
  }
}
