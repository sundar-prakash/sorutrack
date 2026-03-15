import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child; // For complex layouts

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius = 8.0,
    this.child,
  });

  const LoadingShimmer.card({
    super.key,
    this.width = double.infinity,
    this.height = 120.0,
    this.borderRadius = 16.0,
    this.child,
  });

  const LoadingShimmer.circular({
    super.key,
    this.width = 48.0,
    this.height = 48.0,
    this.borderRadius = 24.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    if (child != null) {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: child!,
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
