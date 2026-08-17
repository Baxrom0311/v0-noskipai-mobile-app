import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noskipai/config/app_theme.dart';
import 'package:noskipai/providers/auth_provider.dart';
import 'package:noskipai/providers/medication_provider.dart';
import 'package:noskipai/widgets/bottom_nav_bar.dart';
import 'package:noskipai/widgets/adherence_progress_card.dart';
import 'package:noskipai/widgets/gradient_card.dart';
import 'package:noskipai/widgets/medication_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(medicationProvider.notifier).fetchMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final medState = ref.watch(medicationProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NoSkipAI'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTabChanged: (index) {
            setState(() => _selectedIndex = index);
            _navigateToTab(index, context);
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildMedicationsTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    final medState = ref.watch(medicationProvider);
    final authState = ref.watch(authProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(medicationProvider.notifier).fetchMedications(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            GradientCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${authState.user?.fullName}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep taking your medications on time',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Adherence stats
            Text(
              'Your Adherence',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            AdherenceProgressCard(
              title: 'This Week',
              percentage: 0.85,
              subtitle: 'You\'ve taken 17 of 20 medications',
              progressColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            AdherenceProgressCard(
              title: 'This Month',
              percentage: 0.92,
              subtitle: 'Excellent adherence rate',
              progressColor: AppTheme.accentColor,
            ),
            const SizedBox(height: 24),
            // Today's medications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Medications',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: () {
                    // Show add medication dialog
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (medState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (medState.medications.isEmpty)
              GradientCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication_liquid,
                        size: 48,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No medications added',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: medState.medications
                    .asMap()
                    .entries
                    .map(
                      (entry) => MedicationTile(
                        name: entry.value.name,
                        dosage: entry.value.dosage,
                        frequency: entry.value.frequency,
                        nextTime: entry.value.schedule.isNotEmpty
                            ? entry.value.schedule[0]
                            : 'Not scheduled',
                        isTaken: false,
                        onMarkTaken: () {},
                        onMarkMissed: () {},
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return const Center(
      child: Text('Medications Tab'),
    );
  }

  Widget _buildChatTab() {
    return const Center(
      child: Text('Chat Tab'),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Settings Tab'),
    );
  }

  void _navigateToTab(int index, BuildContext context) {
    switch (index) {
      case 1:
        context.push('/medications');
        break;
      case 2:
        context.push('/chat');
        break;
      case 3:
        context.push('/settings');
        break;
    }
  }
}
