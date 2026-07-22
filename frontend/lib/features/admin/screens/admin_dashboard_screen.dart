import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_dashboard_stats.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_panel_components.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      return AdminErrorView(message: provider.error!, onRetry: provider.load);
    }

    final stats = provider.stats;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 250)
            .floor()
            .clamp(1, 3)
            .toInt();

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(constraints.maxWidth >= 900 ? 32 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminPageHeader(
                title: 'Dashboard',
                subtitle: 'Overview of the adoption platform',
                trailing: IconButton.outlined(
                  onPressed: provider.isLoading ? null : provider.load,
                  tooltip: 'Refresh dashboard',
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(height: 28),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 3.2 : 2.1,
                children: _cards(stats),
              ),
              const SizedBox(height: 20),
              _OverviewGrid(stats: stats),
            ],
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
        description: 'Registered accounts',
      ),
      AdminStatCard(
        label: 'Total pets',
        value: stats.totalPets,
        icon: Icons.pets_outlined,
        description: 'All pet listings',
      ),
      AdminStatCard(
        label: 'Pending pets',
        value: stats.pendingPets,
        icon: Icons.hourglass_empty,
        description: 'Waiting for review',
        highlight: true,
      ),
      AdminStatCard(
        label: 'Total applications',
        value: stats.totalApplications,
        icon: Icons.assignment_outlined,
        description: 'All adoption requests',
      ),
      AdminStatCard(
        label: 'Pending applications',
        value: stats.pendingApplications,
        icon: Icons.pending_actions,
        description: 'Waiting for decision',
        highlight: true,
      ),
    ];
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final children = [
          _ReviewQueue(stats: stats),
          _PlatformOverview(stats: stats),
        ];

        if (!wide) {
          return Column(
            children: [
              children.first,
              const SizedBox(height: 16),
              children.last,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children.first),
            const SizedBox(width: 16),
            Expanded(child: children.last),
          ],
        );
      },
    );
  }
}

class _ReviewQueue extends StatelessWidget {
  const _ReviewQueue({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review queue',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Items that currently need an admin decision',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B665C)),
          ),
          const SizedBox(height: 20),
          _QueueRow(
            icon: Icons.pets_outlined,
            title: 'Pet listings',
            value: stats.pendingPets,
          ),
          const Divider(height: 28),
          _QueueRow(
            icon: Icons.assignment_outlined,
            title: 'Adoption applications',
            value: stats.pendingApplications,
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFFFF3C4),
          foregroundColor: const Color(0xFFAA7D0A),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3C4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value pending',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFFAA7D0A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlatformOverview extends StatelessWidget {
  const _PlatformOverview({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final reviewedPets = (stats.totalPets - stats.pendingPets)
        .clamp(0, stats.totalPets)
        .toInt();
    final reviewedApplications =
        (stats.totalApplications - stats.pendingApplications)
            .clamp(0, stats.totalApplications)
            .toInt();

    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Current moderation progress based on live totals',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B665C)),
          ),
          const SizedBox(height: 20),
          _ProgressRow(
            label: 'Reviewed pet listings',
            value: reviewedPets,
            total: stats.totalPets,
          ),
          const SizedBox(height: 20),
          _ProgressRow(
            label: 'Processed applications',
            value: reviewedApplications,
            total: stats.totalApplications,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
  });

  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$value / $total',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: const Color(0xFFF3EFE7),
            color: const Color(0xFFD4A017),
          ),
        ),
      ],
    );
  }
}
