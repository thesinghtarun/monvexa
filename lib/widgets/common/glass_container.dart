import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable frosted-glass container.
/// Uses BackdropFilter + ImageFilter.blur — no packages required.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.radius = 16.0,
    this.tint = Colors.white,
    this.padding,
    this.showBorder = true,
    this.width,
    this.height,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double radius;
  final Color tint;
  final EdgeInsets? padding;
  final bool showBorder;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: showBorder
                ? Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.0,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
