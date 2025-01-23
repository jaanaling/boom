import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:booms/ui_kit/animated_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonColors color;
  final double topPadding;
  final double bottomPadding;
  final bool isBig;
  final bool isLong;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.topPadding = 4,
    this.bottomPadding = 4,
    this.isLong = false,
    required this.color,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    return onPressed != null
        ? AnimatedButton(
            onPressed: onPressed!,
            child: content(child, color, isBig, isLong),
          )
        : content(child, color, isBig, isLong);
  }
}

Widget content(Widget child, ButtonColors color, bool isBig, bool isLong) {



  return Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(color == ButtonColors.green
            ? 0
            : color == ButtonColors.purple
            ? 13
            :isBig
            ? 47
            :isLong
            ? 20
            : 20,),
        child: AppIcon(
          asset: color == ButtonColors.green || isLong
              ? IconProvider.greenButton.buildImageUrl()
              : isBig
                  ? IconProvider.btn1.buildImageUrl()
                  : IconProvider.smallButton.buildImageUrl(),
          width: color == ButtonColors.green || isLong
              ? 230
              : color == ButtonColors.purple
              ? 58
              : isBig
              ? 294
              : 111,
          height: color == ButtonColors.green || isLong
              ? 59
              : color == ButtonColors.purple
              ? 58
              : isBig
              ? 121
              : 111,
          color: (color == ButtonColors.green && !isLong) || color == ButtonColors.pink
              ? null
              : color == ButtonColors.purple
              ? Color(0xFFA200E2)
              :  color == ButtonColors.orange
              ? Color(0xFFff6402)
              : color == ButtonColors.fGreen
              ? Color(0xFF85ee70)
              : Colors.grey,
          blendMode: (color == ButtonColors.green && !isLong) || color == ButtonColors.pink
              ? null:isLong?BlendMode.modulate: BlendMode.color,
        ),
      ),
      child,
    ],
  );
}

enum ButtonColors { purple, green, grey, orange, pink, fGreen, }
