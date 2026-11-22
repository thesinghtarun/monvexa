import 'package:flutter/material.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class AdShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AdShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface.withOpacity(0.6),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
