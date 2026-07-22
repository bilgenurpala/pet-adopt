import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const String supportEmail = 'support@petadoption.com';
  static const String githubRepository = 'github.com/bilgenurpala/pet-adopt';

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Contact',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2BF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.pets, size: 52, color: Color(0xFFD4A017)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pet Adoption Support',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact the project team for technical support, feedback, or bug reports.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 28),
          Text(
            'Support',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFFD4A017),
                  ),
                  title: const Text('Support Email'),
                  subtitle: const Text(supportEmail),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showMessage(context, 'Support email: $supportEmail');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code, color: Color(0xFFD4A017)),
                  title: const Text('GitHub Repository'),
                  subtitle: const Text(githubRepository),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showMessage(context, 'Repository: $githubRepository');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Contact the Team',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                _TeamMemberTile(
                  name: 'Arjin Özceylan',
                  role: 'Frontend Development',
                  icon: Icons.web_outlined,
                ),
                Divider(height: 1),
                _TeamMemberTile(
                  name: 'Bilge Pala',
                  role: 'Backend and Admin Development',
                  icon: Icons.dns_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Help Us Improve',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                _showMessage(context, 'Bug reporting will be available soon.');
              },
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Report a Bug'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                _showMessage(
                  context,
                  'Feedback submission will be available soon.',
                );
              },
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Send Feedback'),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Pet Adoption Platform • Version 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({
    required this.name,
    required this.role,
    required this.icon,
  });

  final String name;
  final String role;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFFF2BF),
        child: Icon(icon, color: const Color(0xFFD4A017)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(role),
    );
  }
}
