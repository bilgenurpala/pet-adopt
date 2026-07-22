import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_dashboard_stats.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(AdminDashboardProvider provider) {
    if (provider.isLoading && provider.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.stats == null) {
      return AdminErrorView(
        message: provider.error!,
        onRetry: provider.load,
      );
    }

    final stats = provider.stats;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 220).floor().clamp(1, 5);

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: _cards(stats),
          ),
        );
      },
    );
  }

  List<Widget> _cards(AdminDashboardStats stats) {
    return [
      AdminStatCard(
        label: 'Total users',
        value: stats.totalUsers,
        icon: Icons.people_outline,
      ),
      AdminStatCard(
        label: 'Total pets',
        value: stats.totalPets,
        icon: Icons.pets_outlined,
      ),
      AdminStatCard(
        label: 'Pending pets',
        value: stats.pendingPets,
        icon: Icons.hourglass_empty,
        highlight: true,
      ),
      AdminStatCard(
        label: 'Total applications',
        value: stats.totalApplications,
        icon: Icons.assignment_outlined,
      ),
      AdminStatCard(
        label: 'Pending applications',
        value: stats.pendingApplications,
        icon: Icons.pending_actions,
        highlight: true,
      ),
    ];
  }
}
