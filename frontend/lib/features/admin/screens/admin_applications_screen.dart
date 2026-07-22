import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/admin_adoption_application.dart';
import '../providers/admin_applications_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_network_image.dart';

const List<String> _filters = [
  'all',
  'pending',
  'approved',
  'rejected',
  'completed',
];

const Map<String, List<String>> _transitions = {
  'pending': ['approved', 'rejected'],
  'approved': ['completed'],
  'rejected': [],
  'completed': [],
};

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminApplicationsProvider>().load();
    });
  }

  Future<void> _update(AdminAdoptionApplication application, String status) async {
    final message = await context
        .read<AdminApplicationsProvider>()
        .updateStatus(application.id, status);

    if (!mounted) {
      return;
    }

    final text = message ?? 'Application marked as $status.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminApplicationsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: Column(
        children: [
          _FilterBar(
            selected: provider.filter,
            onSelected: (value) =>
                context.read<AdminApplicationsProvider>().setFilter(value),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.load,
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminApplicationsProvider provider) {
    if (provider.isLoading && provider.applications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.applications.isEmpty) {
      return AdminErrorView(message: provider.error!, onRetry: provider.load);
    }

    if (provider.applications.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyState(
            title: 'No applications',
            subtitle: 'There is nothing to review for this filter.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.applications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final application = provider.applications[index];

        return _ApplicationCard(
          application: application,
          isBusy: provider.isBusy(application.id),
          onUpdate: (status) => _update(application, status),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final filter in _filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: selected == filter,
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.isBusy,
    required this.onUpdate,
  });

  final AdminAdoptionApplication application;
  final bool isBusy;
  final ValueChanged<String> onUpdate;

  @override
  Widget build(BuildContext context) {
    final nextStatuses = _transitions[application.status] ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AdminNetworkImage(url: application.petPhotoUrl, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.petName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.applicantName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: application.status),
              ],
            ),
            if (application.message != null) ...[
              const SizedBox(height: 8),
              Text(
                application.message!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (nextStatuses.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final status in nextStatuses)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilledButton.tonal(
                        onPressed: isBusy ? null : () => onUpdate(status),
                        child: Text(status),
                      ),
                    ),
                  if (isBusy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _colorFor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'completed':
        return AppColors.primaryDark;
      default:
        return AppColors.warning;
    }
  }
}
