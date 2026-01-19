import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _shareApp() async {
    await Share.share(
      '🌙 Check out DreamScape - AI Dream Analysis App!\n\nAnalyze your dreams with AI and discover hidden meanings.\n\nDownload now: [Your App Link]',
      subject: 'DreamScape - AI Dream Analysis',
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('About DreamScape'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DreamScape - AI Dream Analysis',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Discover the hidden meanings in your dreams with AI-powered analysis.',
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2026 DreamScape. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Profile Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Freemium User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Free Plan',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Device ID: abc-123...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Upgrade Button (for freemium users)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showComingSoonSnackbar(context, 'Premium upgrade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.diamond),
              label: const Text('Upgrade to Premium'),
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Light'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Theme selection'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Timezone'),
            subtitle: const Text('Asia/Kolkata'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Timezone selection'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Dream reminders and updates'),
            trailing: Switch(
              value: true,
              onChanged: (value) => _showComingSoonSnackbar(context, 'Notification settings'),
            ),
          ),

          const Divider(height: 32),

          // Data & Privacy Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data & Privacy',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Dreams'),
            subtitle: const Text('Download your dreams as PDF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Export dreams'),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Backup & Sync'),
            subtitle: const Text('Sync dreams to cloud'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Backup & sync'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Permanently delete all data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Delete account'),
          ),

          const Divider(height: 32),

          // Support Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Support',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Privacy policy'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Terms of service'),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Rate app'),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _shareApp,
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a Bug'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoonSnackbar(context, 'Bug report'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}













/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Profile Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Freemium User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Device ID: abc-123...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Settings items
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Light'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Timezone'),
            subtitle: const Text('Asia/Kolkata'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(value: false, onChanged: (value) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
*/