import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/adoption_provider.dart';

class AdoptionApplicationsPage extends StatefulWidget {
  const AdoptionApplicationsPage({super.key, this.embedded = false});

  final bool embedded;

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
    final content = Consumer<AdoptionProvider>(
      builder: (context, provider, _) {
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
                  subtitle:
                      provider.errorMessage ?? 'An unknown error occurred.',
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
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final adoption = provider.applications[index];

              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ApplicationPetImage(imageUrl: adoption.petImageUrl),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adoption.petName.isEmpty
                                  ? 'Pet #${adoption.petId}'
                                  : adoption.petName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Application #${adoption.id}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Applied on ${_formatDate(adoption.createdAt)}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 10),
                            _StatusChip(status: adoption.status),
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
    );

    if (widget.embedded) {
      return content;
    }

    return AppScaffold(title: 'Adoption Applications', body: content);
  }

  static String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day.$month.${localDate.year}';
  }
}

class _ApplicationPetImage extends StatelessWidget {
  const _ApplicationPetImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2BF),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? const _PlaceholderIcon()
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const _PlaceholderIcon();
              },
            ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.pets, size: 36, color: Color(0xFFD4A017));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();

    final color = _statusColor(normalizedStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(normalizedStatus),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) {
      return 'Pending';
    }

    return '${status[0].toUpperCase()}'
        '${status.substring(1)}';
  }
}
