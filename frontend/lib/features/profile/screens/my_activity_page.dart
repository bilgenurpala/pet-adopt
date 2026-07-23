import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../adoptions/screens/adoption_applications_page.dart';
import 'my_pet_listings_page.dart';

class MyActivityPage extends StatelessWidget {
  const MyActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Activity'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.pets_outlined), text: 'My Listings'),
              Tab(
                icon: Icon(Icons.assignment_outlined),
                text: 'My Applications',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyPetListingsPage(embedded: true),
            AdoptionApplicationsPage(embedded: true),
          ],
        ),
      ),
    );
  }
}
