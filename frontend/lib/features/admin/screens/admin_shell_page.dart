import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_breakpoints.dart';
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
    label: 'Pending',
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

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= AppBreakpoints.tablet;

    final body = IndexedStack(index: _selectedIndex, children: _screens);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
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
