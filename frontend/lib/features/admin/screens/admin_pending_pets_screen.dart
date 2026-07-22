import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_state.dart';
import '../../pets/models/pet.dart';
import '../providers/admin_pending_pets_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_network_image.dart';

class AdminPendingPetsScreen extends StatefulWidget {
  const AdminPendingPetsScreen({super.key});

  @override
  State<AdminPendingPetsScreen> createState() => _AdminPendingPetsScreenState();
}

class _AdminPendingPetsScreenState extends State<AdminPendingPetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPendingPetsProvider>().load();
    });
  }

  Future<void> _approve(Pet pet) async {
    final message = await context.read<AdminPendingPetsProvider>().approve(pet.id);
    _showResult(message, '${pet.name} approved.');
  }

  Future<void> _reject(Pet pet) async {
    final confirmed = await _confirm(
      title: 'Reject listing',
      body: 'Delete "${pet.name}"? This cannot be undone.',
    );

    if (!confirmed) {
      return;
    }

    final message = await context.read<AdminPendingPetsProvider>().reject(pet.id);
    _showResult(message, '${pet.name} rejected.');
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showResult(String? errorMessage, String successMessage) {
    if (!mounted) {
      return;
    }

    final text = errorMessage ?? successMessage;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminPendingPetsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Pets')),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(AdminPendingPetsProvider provider) {
    if (provider.isLoading && provider.pets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.pets.isEmpty) {
      return AdminErrorView(message: provider.error!, onRetry: provider.load);
    }

    if (provider.pets.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyState(
            title: 'No pending pets',
            subtitle: 'Every listing has been reviewed.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.pets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pet = provider.pets[index];

        return _PendingPetCard(
          pet: pet,
          isBusy: provider.isBusy(pet.id),
          onApprove: () => _approve(pet),
          onReject: () => _reject(pet),
        );
      },
    );
  }
}

class _PendingPetCard extends StatelessWidget {
  const _PendingPetCard({
    required this.pet,
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
  });

  final Pet pet;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AdminNetworkImage(url: pet.photoUrl, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.species} · ${pet.breed}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : onApprove,
                    icon: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
