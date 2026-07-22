import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/admin_user_summary.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_error_view.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().load();
    });
  }

  Future<void> _changeRole(AdminUserSummary user) async {
    final nextRole = user.isAdmin ? 'user' : 'admin';
    final message =
        await context.read<AdminUsersProvider>().changeRole(user.id, nextRole);
    _showResult(message, '${user.fullName} is now $nextRole.');
  }

  Future<void> _delete(AdminUserSummary user) async {
    final confirmed = await _confirm(
      title: 'Delete user',
      body: 'Delete "${user.fullName}"? This cannot be undone.',
    );

    if (!confirmed) {
      return;
    }

    final message =
        await context.read<AdminUsersProvider>().deleteUser(user.id);
    _showResult(message, '${user.fullName} deleted.');
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
    final provider = context.watch<AdminUsersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(AdminUsersProvider provider) {
    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.users.isEmpty) {
      return AdminErrorView(message: provider.error!, onRetry: provider.load);
    }

    if (provider.users.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyState(
            title: 'No users',
            subtitle: 'There are no accounts to manage.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = provider.users[index];

        return _UserCard(
          user: user,
          isBusy: provider.isBusy(user.id),
          isSelf: provider.isSelf(user.id),
          onChangeRole: () => _changeRole(user),
          onDelete: () => _delete(user),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isBusy,
    required this.isSelf,
    required this.onChangeRole,
    required this.onDelete,
  });

  final AdminUserSummary user;
  final bool isBusy;
  final bool isSelf;
  final VoidCallback onChangeRole;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canModify = !isBusy && !isSelf;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _RoleChip(role: user.role),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: canModify ? onChangeRole : null,
                    child: Text(user.isAdmin ? 'Make user' : 'Make admin'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canModify ? onDelete : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    icon: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            if (isSelf) ...[
              const SizedBox(height: 8),
              Text(
                'This is your account.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    final color = isAdmin ? AppColors.primaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
