import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool isAnimationComplete = false;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController for slide-out animation
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 500), // Adjust duration for sliding
    );

    // Define slide animation (to the left of the screen)
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0), // Moves 1.5x screen width to the left
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375.w,
      height: 400.h,
      child: Stack(
        children: [
          // Lottie animation wrapped in SlideTransition
          SlideTransition(
            position: _slideAnimation,
            child: LottieBuilder.asset(
              "assets/animation/delivery4.json",
              width: 375.w,
              height: 400.h,
              repeat: false,
              onLoaded: (composition) {
                // Start sliding out after Lottie animation completes
                Future.delayed(composition.duration, () {
                  setState(() {
                    isAnimationComplete = true;
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up animation controller
    super.dispose();
  }
}
