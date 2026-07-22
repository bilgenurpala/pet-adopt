import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/adoption_provider.dart';

class AdoptionApplicationsPage extends StatefulWidget {
  const AdoptionApplicationsPage({super.key});

  @override
  State<AdoptionApplicationsPage> createState() =>
      _AdoptionApplicationsPageState();
}

class _AdoptionApplicationsPageState extends State<AdoptionApplicationsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdoptionProvider>().loadApplications();
    });
  }

  Future<void> _refresh() async {
    await context.read<AdoptionProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Adoption Applications',
      body: Consumer<AdoptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.applications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.applications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 150),
                  EmptyState(
                    title: 'Unable to load applications',
                    subtitle: provider.errorMessage ?? 'Unknown error',
                  ),
                ],
              ),
            );
          }

          if (provider.applications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  EmptyState(
                    title: 'No Applications Yet',
                    subtitle: 'Applications you submit will appear here.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.applications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final adoption = provider.applications[index];

                return Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF2BF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: adoption.petImageUrl == null
                              ? const Icon(
                                  Icons.pets,
                                  size: 36,
                                  color: Color(0xffD4A017),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    adoption.petImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.pets,
                                        size: 36,
                                        color: Color(0xffD4A017),
                                      );
                                    },
                                  ),
                                ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adoption.petName.isEmpty
                                    ? 'Pet #${adoption.petId}'
                                    : adoption.petName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("Application ID : ${adoption.id}"),
                              const SizedBox(height: 6),
                              Text(
                                "Applied : ${adoption.createdAt.day.toString().padLeft(2, '0')}.${adoption.createdAt.month.toString().padLeft(2, '0')}.${adoption.createdAt.year}",
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    adoption.status,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  adoption.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _statusColor(adoption.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "cancelled":
        return Colors.grey;

      default:
        return Colors.orange;
    }
  }
}
