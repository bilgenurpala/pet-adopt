import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/router/route_names.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/admin_applications_provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/admin_pending_pets_provider.dart';
import '../providers/admin_users_provider.dart';
import 'admin_applications_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_pending_pets_screen.dart';
import 'admin_users_screen.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminPendingPetsProvider()),
        ChangeNotifierProvider(create: (_) => AdminApplicationsProvider()),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
      ],
      child: const _AdminShellView(),
    );
  }
}

class _AdminDestination {
  const _AdminDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const List<_AdminDestination> _destinations = [
  _AdminDestination(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
  ),
  _AdminDestination(
    icon: Icons.pets_outlined,
    selectedIcon: Icons.pets,
    label: 'Pets',
  ),
  _AdminDestination(
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    label: 'Applications',
  ),
  _AdminDestination(
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    label: 'Users',
  ),
];

class _AdminShellView extends StatefulWidget {
  const _AdminShellView();

  @override
  State<_AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<_AdminShellView> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    AdminDashboardScreen(),
    AdminPendingPetsScreen(),
    AdminApplicationsScreen(),
    AdminUsersScreen(),
  ];

  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) {
      return;
    }

    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isWide = MediaQuery.of(context).size.width >= AppBreakpoints.tablet;

    final body = IndexedStack(index: _selectedIndex, children: _screens);

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: [
              _AdminSidebar(
                selectedIndex: _selectedIndex,
                onSelected: _onSelect,
                adminEmail: currentUser?.email ?? '',
                onLogout: authProvider.isLoading ? null : _logout,
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_selectedIndex].label),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: authProvider.isLoading ? null : _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onSelect,
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedIndex,
    required this.onSelected,
    required this.adminEmail,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String adminEmail;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 20, 24),
            child: Row(
              children: [
                _BrandMark(),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pet Adoption',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Admin portal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 20),
          for (var index = 0; index < _destinations.length; index++)
            _SidebarItem(
              destination: _destinations[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Administrator',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              adminEmail.isEmpty
                                  ? 'Management access'
                                  : adminEmail,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, size: 19),
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.pets, color: Colors.white, size: 23),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _AdminDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: selected ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 21,
                  color: selected
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    destination.label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
