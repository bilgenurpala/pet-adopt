import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/admin_user_summary.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_panel_components.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().load();
    });
  }

  List<AdminUserSummary> _visibleUsers(List<AdminUserSummary> users) {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _changeRole(AdminUserSummary user) async {
    final nextRole = user.isAdmin ? 'user' : 'admin';
    final message = await context.read<AdminUsersProvider>().changeRole(
      user.id,
      nextRole,
    );
    _showResult(message, '${user.fullName} is now $nextRole.');
  }

  Future<void> _edit(AdminUserSummary user) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UserEditDialog(user: user),
    );

    if (data == null || !mounted) {
      return;
    }

    final message = await context.read<AdminUsersProvider>().updateUser(
      user.id,
      data,
    );
    _showResult(message, '${user.fullName} updated.');
  }

  Future<void> _delete(AdminUserSummary user) async {
    final confirmed = await _confirm(
      title: 'Delete user',
      body: 'Delete "${user.fullName}"? This cannot be undone.',
    );

    if (!confirmed || !mounted) {
      return;
    }

    final message = await context.read<AdminUsersProvider>().deleteUser(
      user.id,
    );
    _showResult(message, '${user.fullName} deleted.');
  }

  void _showDetails(AdminUserSummary user) {
    showDialog<void>(
      context: context,
      builder: (context) => _UserDetailDialog(
        user: user,
        onEdit: () {
          Navigator.of(context).pop();
          _edit(user);
        },
      ),
    );
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage ?? successMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

    final users = _visibleUsers(provider.users);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(wide ? 32 : 20),
          children: [
            const AdminPageHeader(
              title: 'Users',
              subtitle: 'Manage registered users and admin access',
            ),
            const SizedBox(height: 24),
            AdminSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${provider.users.length} registered users',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      AdminSearchField(
                        hintText: 'Search users...',
                        onChanged: (value) {
                          setState(() => _query = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 56),
                      child: EmptyState(
                        title: 'No users found',
                        subtitle: 'Try a different search.',
                      ),
                    )
                  else if (wide)
                    _UsersTable(
                      users: users,
                      provider: provider,
                      onView: _showDetails,
                      onEdit: _edit,
                      onChangeRole: _changeRole,
                      onDelete: _delete,
                    )
                  else
                    _UsersList(
                      users: users,
                      provider: provider,
                      onView: _showDetails,
                      onEdit: _edit,
                      onChangeRole: _changeRole,
                      onDelete: _delete,
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

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.users,
    required this.provider,
    required this.onView,
    required this.onEdit,
    required this.onChangeRole,
    required this.onDelete,
  });

  final List<AdminUserSummary> users;
  final AdminUsersProvider provider;
  final ValueChanged<AdminUserSummary> onView;
  final ValueChanged<AdminUserSummary> onEdit;
  final ValueChanged<AdminUserSummary> onChangeRole;
  final ValueChanged<AdminUserSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).scaffoldBackgroundColor,
        ),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Username')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final user in users)
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Row(
                      children: [
                        _UserAvatar(user: user),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text('@${user.username}')),
                DataCell(SizedBox(width: 210, child: Text(user.email))),
                DataCell(AdminStatusBadge(status: user.role)),
                DataCell(
                  _UserActions(
                    user: user,
                    isBusy: provider.isBusy(user.id),
                    isSelf: provider.isSelf(user.id),
                    onView: () => onView(user),
                    onEdit: () => onEdit(user),
                    onChangeRole: () => onChangeRole(user),
                    onDelete: () => onDelete(user),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({
    required this.users,
    required this.provider,
    required this.onView,
    required this.onEdit,
    required this.onChangeRole,
    required this.onDelete,
  });

  final List<AdminUserSummary> users;
  final AdminUsersProvider provider;
  final ValueChanged<AdminUserSummary> onView;
  final ValueChanged<AdminUserSummary> onEdit;
  final ValueChanged<AdminUserSummary> onChangeRole;
  final ValueChanged<AdminUserSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < users.length; index++) ...[
          _UserCard(
            user: users[index],
            isBusy: provider.isBusy(users[index].id),
            isSelf: provider.isSelf(users[index].id),
            onView: () => onView(users[index]),
            onEdit: () => onEdit(users[index]),
            onChangeRole: () => onChangeRole(users[index]),
            onDelete: () => onDelete(users[index]),
          ),
          if (index != users.length - 1) const Divider(height: 28),
        ],
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isBusy,
    required this.isSelf,
    required this.onView,
    required this.onEdit,
    required this.onChangeRole,
    required this.onDelete,
  });

  final AdminUserSummary user;
  final bool isBusy;
  final bool isSelf;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onChangeRole;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canModify = !isBusy && !isSelf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _UserAvatar(user: user, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(user.email),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AdminStatusBadge(status: user.role),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: onView,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: isBusy ? null : onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: canModify ? onChangeRole : null,
              child: Text(user.isAdmin ? 'Make user' : 'Make admin'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                foregroundColor: AppColors.error,
              ),
              onPressed: canModify ? onDelete : null,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
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
    );
  }
}

class _UserActions extends StatelessWidget {
  const _UserActions({
    required this.user,
    required this.isBusy,
    required this.isSelf,
    required this.onView,
    required this.onEdit,
    required this.onChangeRole,
    required this.onDelete,
  });

  final AdminUserSummary user;
  final bool isBusy;
  final bool isSelf;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onChangeRole;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canModify = !isBusy && !isSelf;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminIconAction(
          icon: Icons.visibility_outlined,
          tooltip: 'View user',
          onPressed: onView,
        ),
        AdminIconAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit user',
          onPressed: isBusy ? null : onEdit,
        ),
        AdminIconAction(
          icon: user.isAdmin
              ? Icons.person_outline
              : Icons.admin_panel_settings_outlined,
          tooltip: user.isAdmin ? 'Make user' : 'Make admin',
          onPressed: canModify ? onChangeRole : null,
        ),
        AdminIconAction(
          icon: Icons.delete_outline,
          tooltip: 'Delete user',
          color: AppColors.error,
          onPressed: canModify ? onDelete : null,
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, this.radius = 20});

  final AdminUserSummary user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primaryDark,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _UserDetailDialog extends StatelessWidget {
  const _UserDetailDialog({required this.user, required this.onEdit});

  final AdminUserSummary user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'User details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _UserAvatar(user: user, radius: 34),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        AdminStatusBadge(status: user.role),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AdminDetailRow(label: 'User ID', value: '${user.id}'),
              AdminDetailRow(label: 'Username', value: user.username),
              AdminDetailRow(label: 'Email', value: user.email),
              AdminDetailRow(label: 'Role', value: user.role),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserEditDialog extends StatefulWidget {
  const _UserEditDialog({required this.user});

  final AdminUserSummary user;

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _username;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.user.fullName);
    _username = TextEditingController(text: widget.user.username);
    _email = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Required';
    }

    return text.contains('@') ? null : 'Enter a valid email';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(<String, dynamic>{
      'full_name': _fullName.text.trim(),
      'username': _username.text.trim(),
      'email': _email.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit user'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullName,
                validator: _required,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _username,
                validator: _required,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save changes')),
      ],
    );
  }
}
