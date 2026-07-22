import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _refreshProfile() async {
    await context.read<AuthProvider>().refreshCurrentUser();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return AppScaffold(
      title: 'Profile',
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            if (authProvider.isLoading && user == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                user?.displayName ?? 'User',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.isAdmin ? 'Administrator' : '@${user.username}',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],

            if (authProvider.errorMessage != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  authProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],

            const SizedBox(height: 28),

            _ProfileTile(
              icon: Icons.favorite_outline,
              title: 'Favorite Pets',
              subtitle: 'View the pets you saved',
              onTap: () {
                context.push(RouteNames.favorites);
              },
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.dashboard_customize_outlined,
              title: 'My Activity',
              subtitle: 'View your listings and adoption applications',
              onTap: () {
                context.push(RouteNames.myActivity);
              },
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.info_outline,
              title: 'About Pet Adoption',
              subtitle: 'Learn more about the platform',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Pet Adoption',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.pets,
                    size: 42,
                    color: AppColors.primary,
                  ),
                  children: const [
                    Text(
                      'A platform that helps pets find safe and loving homes.',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.contact_support_outlined,
              title: 'Contact',
              subtitle: 'Get help and support',
              onTap: () {
                context.push(RouteNames.contact);
              },
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Manage application preferences',
              onTap: () {
                context.push(RouteNames.settings);
              },
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              iconColor: AppColors.error,
              onTap: authProvider.isLoading ? null : _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.primaryDark;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor == null
                ? AppColors.primaryLight
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: resolvedIconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: iconColor),
        ),
        subtitle: Text(subtitle),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
