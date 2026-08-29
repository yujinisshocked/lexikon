import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
        // Privacy and Security Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Privacy and Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
            ),
        const ListTile(
          leading: Icon(Icons.security),
          title: Text('Privacy and Security'),
          subtitle: Text('All data is stored locally and never shared'),
            ),
          ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Enable Encryption'),
            trailing: Switch(
              value: false, // Replace with actual state
              onChanged: (value) {
              // Toggle encryption
              },
            ),
          ),
          ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Biometric Lock'),
          trailing: Switch(
            value: false, // Replace with actual state
            onChanged: (value) {
              // Toggle biometric lock
            },
          ),
          ),
        const Divider(),
        // User Preferences Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'User Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Theme'),
          trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
            // Navigate to theme selection
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
            // Navigate to language selection
          },
        ),
        const Divider(),
        // App Features Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'App Features',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: Switch(
            value: true, // Replace with actual state
            onChanged: (value) {
              // Toggle notifications
          },
        ),
        ),
        const Divider(),
        // Data Management Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Data Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup Data'),
          onTap: () {
            // Backup data to local storage
          },
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore Data'),
          onTap: () {
            // Restore data from local storage
          },
        ),
        const Divider(),
        // About and Support Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'About and Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About Lexikon'),
          onTap: () {
            // Show about dialog
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Send Feedback'),
          onTap: () {
            // Open feedback form (e.g., email or GitHub)
          },
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Open Source License'),
          onTap: () {
            // Show open-source license
          },
        ),
      ],
    );
  }
}