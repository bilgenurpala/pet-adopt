import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      body: ListView(
        children: [
          const SizedBox(height: 12),

          const CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 52, color: AppColors.primary),
          ),

          const SizedBox(height: 16),

          Text(
            'Guest User',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Not signed in',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 28),

          _ProfileTile(
            icon: Icons.favorite_outline,
            title: 'Favorite Pets',
            subtitle: 'View the pets you saved',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _ProfileTile(
            icon: Icons.assignment_outlined,
            title: 'Adoption Applications',
            subtitle: 'Track your adoption requests',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _ProfileTile(
            icon: Icons.info_outline,
            title: 'About Pet Adoption',
            subtitle: 'Learn more about the platform',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _ProfileTile(
            icon: Icons.contact_support_outlined,
            title: 'Contact',
            subtitle: 'Get help and support',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage application preferences',
            onTap: () {},
          ),
        ],
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryDark),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
