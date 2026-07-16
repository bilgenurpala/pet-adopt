import 'package:flutter/material.dart';

import '../constants/app_breakpoints.dart';

class Responsive {
  const Responsive._();

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return width >= AppBreakpoints.mobile && width < AppBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppBreakpoints.desktop;
  }
}
