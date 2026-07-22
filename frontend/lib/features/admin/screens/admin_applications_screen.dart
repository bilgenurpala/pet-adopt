import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/admin_adoption_application.dart';
import '../providers/admin_applications_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_network_image.dart';
import '../widgets/admin_panel_components.dart';

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
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminApplicationsProvider>().load();
    });
  }

  List<AdminAdoptionApplication> _visibleApplications(
    List<AdminAdoptionApplication> applications,
  ) {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return applications;
    }

    return applications.where((application) {
      return application.petName.toLowerCase().contains(query) ||
          application.applicantName.toLowerCase().contains(query) ||
          application.applicantEmail.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _update(
    AdminAdoptionApplication application,
    String status,
  ) async {
    final message = await context
        .read<AdminApplicationsProvider>()
        .updateStatus(application.id, status);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message ?? 'Application marked as $status.')),
      );
  }

  void _showDetails(AdminAdoptionApplication application) {
    showDialog<void>(
      context: context,
      builder: (context) => _ApplicationDetailDialog(
        application: application,
        isBusy: context.read<AdminApplicationsProvider>().isBusy(
          application.id,
        ),
        onUpdate: (status) {
          Navigator.of(context).pop();
          _update(application, status);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminApplicationsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: _buildBody(provider),
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

    final applications = _visibleApplications(provider.applications);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(wide ? 32 : 20),
          children: [
            const AdminPageHeader(
              title: 'Adoption applications',
              subtitle: 'Review and manage adoption requests',
            ),
            const SizedBox(height: 24),
            AdminSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ApplicationsToolbar(
                    selected: provider.filter,
                    onSelected: (value) {
                      context.read<AdminApplicationsProvider>().setFilter(
                        value,
                      );
                    },
                    onSearchChanged: (value) {
                      setState(() => _query = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  if (applications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 56),
                      child: EmptyState(
                        title: 'No applications',
                        subtitle: 'There is nothing to review for this filter.',
                      ),
                    )
                  else if (wide)
                    _ApplicationsTable(
                      applications: applications,
                      provider: provider,
                      onView: _showDetails,
                      onUpdate: _update,
                    )
                  else
                    _ApplicationsList(
                      applications: applications,
                      provider: provider,
                      onView: _showDetails,
                      onUpdate: _update,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ApplicationsToolbar extends StatelessWidget {
  const _ApplicationsToolbar({
    required this.selected,
    required this.onSelected,
    required this.onSearchChanged,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in _filters)
              ChoiceChip(
                label: Text(_capitalize(filter)),
                selected: selected == filter,
                onSelected: (_) => onSelected(filter),
              ),
          ],
        ),
        AdminSearchField(
          hintText: 'Search applications...',
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}

class _ApplicationsTable extends StatelessWidget {
  const _ApplicationsTable({
    required this.applications,
    required this.provider,
    required this.onView,
    required this.onUpdate,
  });

  final List<AdminAdoptionApplication> applications;
  final AdminApplicationsProvider provider;
  final ValueChanged<AdminAdoptionApplication> onView;
  final void Function(AdminAdoptionApplication, String) onUpdate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).scaffoldBackgroundColor,
        ),
        columns: const [
          DataColumn(label: Text('Pet')),
          DataColumn(label: Text('Applicant')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final application in applications)
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 170,
                    child: Row(
                      children: [
                        AdminNetworkImage(
                          url: application.petPhotoUrl,
                          size: 42,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            application.petName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 190,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicantName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          application.applicantEmail,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(_formatDate(application.createdAt))),
                DataCell(AdminStatusBadge(status: application.status)),
                DataCell(
                  _ApplicationActions(
                    application: application,
                    isBusy: provider.isBusy(application.id),
                    onView: () => onView(application),
                    onUpdate: (status) => onUpdate(application, status),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ApplicationsList extends StatelessWidget {
  const _ApplicationsList({
    required this.applications,
    required this.provider,
    required this.onView,
    required this.onUpdate,
  });

  final List<AdminAdoptionApplication> applications;
  final AdminApplicationsProvider provider;
  final ValueChanged<AdminAdoptionApplication> onView;
  final void Function(AdminAdoptionApplication, String) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < applications.length; index++) ...[
          _ApplicationCard(
            application: applications[index],
            isBusy: provider.isBusy(applications[index].id),
            onView: () => onView(applications[index]),
            onUpdate: (status) => onUpdate(applications[index], status),
          ),
          if (index != applications.length - 1) const Divider(height: 28),
        ],
      ],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.isBusy,
    required this.onView,
    required this.onUpdate,
  });

  final AdminAdoptionApplication application;
  final bool isBusy;
  final VoidCallback onView;
  final ValueChanged<String> onUpdate;

  @override
  Widget build(BuildContext context) {
    final nextStatuses = _transitions[application.status] ?? const [];

    return Column(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(application.applicantName),
                  Text(
                    application.applicantEmail,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AdminStatusBadge(status: application.status),
          ],
        ),
        if (application.message != null) ...[
          const SizedBox(height: 10),
          Text(
            application.message!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: onView,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View details'),
            ),
            for (final status in nextStatuses)
              FilledButton(
                onPressed: isBusy ? null : () => onUpdate(status),
                child: Text(status),
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
    );
  }
}

class _ApplicationActions extends StatelessWidget {
  const _ApplicationActions({
    required this.application,
    required this.isBusy,
    required this.onView,
    required this.onUpdate,
  });

  final AdminAdoptionApplication application;
  final bool isBusy;
  final VoidCallback onView;
  final ValueChanged<String> onUpdate;

  @override
  Widget build(BuildContext context) {
    final nextStatuses = _transitions[application.status] ?? const [];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminIconAction(
          icon: Icons.visibility_outlined,
          tooltip: 'View application',
          onPressed: onView,
        ),
        for (final status in nextStatuses)
          AdminIconAction(
            icon: status == 'rejected'
                ? Icons.close
                : status == 'completed'
                ? Icons.task_alt
                : Icons.check,
            tooltip: 'Mark as $status',
            onPressed: isBusy ? null : () => onUpdate(status),
          ),
      ],
    );
  }
}

class _ApplicationDetailDialog extends StatelessWidget {
  const _ApplicationDetailDialog({
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

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 650),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Application details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  AdminNetworkImage(url: application.petPhotoUrl, size: 72),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application for ${application.petName}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        AdminStatusBadge(status: application.status),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Applicant information',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AdminDetailRow(label: 'Name', value: application.applicantName),
              AdminDetailRow(label: 'Email', value: application.applicantEmail),
              AdminDetailRow(
                label: 'Application date',
                value: _formatDate(application.createdAt),
              ),
              const SizedBox(height: 18),
              Text(
                'Application message',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.message?.trim().isNotEmpty == true
                      ? application.message!
                      : 'No message provided.',
                ),
              ),
              if (nextStatuses.isNotEmpty) ...[
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final status in nextStatuses)
                      FilledButton.icon(
                        onPressed: isBusy ? null : () => onUpdate(status),
                        icon: Icon(
                          status == 'rejected' ? Icons.close : Icons.check,
                        ),
                        label: Text('Mark as $status'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return 'Not available';
  }

  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}${value.substring(1)}';
}
