// lib/shared/utils/responsive.dart
import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 900;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 40.0;
    if (w >= 600) return 24.0;
    return 16.0;
  }

  static double verticalPadding(BuildContext context) {
    return isMobile(context) ? 16.0 : 24.0;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 600) return 2;
    return 2;
  }

  static int statsGridCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 4;
    return 2;
  }

  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 1200;
    if (w >= 900) return w - 80;
    return w;
  }

  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: horizontalPadding(context),
        vertical: verticalPadding(context),
      );
}
