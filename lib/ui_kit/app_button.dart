import 'package:booms/src/core/utils/app_icon.dart';
import 'package:booms/src/core/utils/icon_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double radius;

  final double width;
  final double height;
  final double topPadding;
  final double bottomPadding;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.radius = 14,
    required this.width,
    this.topPadding = 4,
    this.bottomPadding = 4,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppIcon(
              width: width,
              height: height,
              asset: IconProvider.btn1.buildImageUrl(),
            //  color: Colors.green,
            //  blendMode: BlendMode.modulate,
              fit: BoxFit.fill,
            ),
            child,
            ClipPath(
              clipper: ImageClipper(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  child: Ink(
                    width: width,
                    height: height,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Автоматически добавляем закругленный прямоугольник
    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: Radius.circular(size.height / 2), // Примерная оценка радиуса
      topRight: Radius.circular(size.height / 2),
      bottomLeft: Radius.circular(size.height / 2),
      bottomRight: Radius.circular(size.height / 2),
    ));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
