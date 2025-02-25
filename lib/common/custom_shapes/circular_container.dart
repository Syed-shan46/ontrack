import 'package:flutter/material.dart';


class MyCircularContainer extends StatelessWidget {
  const MyCircularContainer({
    super.key,
    this.width,
    this.height,
    this.radius = 16,
    this.child,
    this.backgroundColor = Colors.white,
    this.padding,
    this.margin,
    this.borderColor = Colors.blue,
    this.showBorder = false,
  });

  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
        border: showBorder ? Border.all(color: Colors.grey) : null,
      ),
      child: child,
    );
  }
}
