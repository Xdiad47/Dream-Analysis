import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dream_journal/presentation/screens/home_screen.dart';
import 'dream_journal/presentation/screens/add_dream_screen.dart';
import 'insights/presentation/screens/insights_screen.dart';
import 'settings/presentation/screens/settings_screen.dart';
import 'dream_journal/presentation/providers/dream_provider.dart';
import '../core/utils/page_transitions.dart';


// Provider to manage selected tab
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    // List of screens
    final screens = [
      const HomeScreen(),
      const InsightsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to Add Dream Screen with animation
          final result = await Navigator.push(
            context,
            PageTransitions.slideFromBottom(const AddDreamScreen()),
          );

          // Reload dreams if saved successfully
          if (result == true) {
            ref.read(dreamsProvider.notifier).loadDreams();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Dream'),
      )
          : null,

    );
  }
}















/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dream_journal/presentation/screens/home_screen.dart';
import 'insights/presentation/screens/insights_screen.dart';
import 'settings/presentation/screens/settings_screen.dart';

// Provider to manage selected tab
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    // List of screens
    final screens = [
      const HomeScreen(),
      const InsightsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Add Dream Screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Dream - Coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Dream'),
      )
          : null,
    );
  }
}
*/