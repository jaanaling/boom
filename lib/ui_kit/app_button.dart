import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:booms/ui_kit/animated_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double radius;
  final bool isGrey;
  final bool isGreen;

  final double width;
  final double height;
  final double topPadding;
  final double bottomPadding;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.radius = 14,
    this.isGreen = false,
    this.isGrey = false,
    required this.width,
    this.topPadding = 4,
    this.bottomPadding = 4,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return onPressed != null
        ? AnimatedButton(
            onPressed: onPressed!,
            child: content(width, height, child, isGrey, isGreen),
          )
        : content(width, height, child, isGrey, isGreen);
  }
}

Widget content(
    double width, double height, Widget child, bool isGrey, bool isGreen) {
  return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppIcon(
            width: width,
            height: height,
            fit: BoxFit.fill,
            asset: IconProvider.btn1.buildImageUrl(),
            color: isGreen? Color.fromARGB(228, 0, 121, 255) : isGrey? Colors.grey: null,
            blendMode: isGreen
                ? BlendMode.modulate
                : isGrey
                    ? BlendMode.modulate
                    : null,
          ),
          child,
        ],
      ));
}
