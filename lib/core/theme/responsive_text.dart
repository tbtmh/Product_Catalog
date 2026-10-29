import 'package:flutter/material.dart';

class ResponsiveTextScale extends StatelessWidget {
  final Widget child;

  const ResponsiveTextScale({super.key, required this.child});

  static const double systemMin = 0.85;
  static const double systemMax = 1.3;

  static const double minScale = 0.9;
  static const double maxScale = 1.5;

  static double layoutFactor(double width) {
    if (width < 360) return 0.95;
    if (width < 600) return 1.0; // mobile
    if (width < 900) return 1.1; // tablet
    return 1.2; // large tablet / desktop
  }

  static double effectiveScale(double width, double systemScale) {
    final system = systemScale.clamp(systemMin, systemMax);
    return (system * layoutFactor(width)).clamp(minScale, maxScale);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final systemScale = mq.textScaler.scale(14) / 14;
    final scale = effectiveScale(mq.size.width, systemScale);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(scale)),
      child: child,
    );
  }
}
