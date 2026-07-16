import 'package:flutter/material.dart';

import '../utils/responsive.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.body, this.title, this.actions, super.key});

  final Widget body;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Pet Store'), actions: actions),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: body,
        ),
      ),
    );
  }
}
