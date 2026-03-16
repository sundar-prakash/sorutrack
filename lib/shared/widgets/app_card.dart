import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation,
      shape: shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
    );
  }
}
