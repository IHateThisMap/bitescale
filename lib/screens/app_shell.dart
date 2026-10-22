import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/user_profile.dart';
import '../services/incoming_files.dart';
import '../services/profile_storage.dart';
import 'food_log_screen.dart';
import 'height_setup_screen.dart';
import 'import_foods_screen.dart';
import 'weight_screen.dart';

/// Loads the user profile, asks for the height if it's missing, and then
/// shows the main pages.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _storage = ProfileStorage();
  UserProfile? _profile;
  double? _latestWeightKg;
  int _page = 0;

  /// Changes when foods are imported, so the food page reloads them.
  int _foodsVersion = 0;

  @override
  void initState() {
    super.initState();
    _storage.load().then((p) {
      if (mounted) setState(() => _profile = p);
    });
    IncomingFiles.listen(_onIncomingFile);
  }

  /// A food file someone sent was opened with the app: review and import.
  Future<void> _onIncomingFile(List<int> bytes) async {
    if (!mounted) return;
    final result = await importFoodFile(context, bytes);
    if (result != null && mounted) setState(() => _foodsVersion++);
  }

  Future<void> _updateProfile(UserProfile profile) async {
    setState(() => _profile = profile);
    await _storage.save(profile);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile.heightCm == null) {
      return HeightSetupScreen(
        onSaved: (h) => _updateProfile(profile.withHeight(h)),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _page,
        children: [
          WeightScreen(
            profile: profile,
            onProfileChanged: _updateProfile,
            onEntriesChanged: (entries) => setState(() => _latestWeightKg =
                entries.isEmpty ? null : entries.last.weightKg),
          ),
          FoodLogScreen(
            key: ValueKey(_foodsVersion),
            profile: profile,
            latestWeightKg: _latestWeightKg,
            onProfileChanged: _updateProfile,
            onShowWeightPage: () => setState(() => _page = 0),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (i) => setState(() => _page = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.monitor_weight_outlined),
            selectedIcon: const Icon(Icons.monitor_weight),
            label: context.l10n.weight,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant),
            label: context.l10n.food,
          ),
        ],
      ),
    );
  }
}
