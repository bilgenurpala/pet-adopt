import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Pet Store',
      body: Center(
        child: Text(
          'Welcome to Pet Store!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
