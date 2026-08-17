import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/config/app_theme.dart';
import 'package:noskipai/providers/medication_provider.dart';
import 'package:noskipai/widgets/gradient_card.dart';
import 'package:noskipai/widgets/medication_tile.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(medicationProvider.notifier).fetchMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final medState = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(medicationProvider.notifier).fetchMedications(),
        child: medState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : medState.medications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_liquid,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No medications yet',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first medication to get started',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medState.medications.length,
                    itemBuilder: (context, index) {
                      final med = medState.medications[index];
                      return MedicationTile(
                        name: med.name,
                        dosage: med.dosage,
                        frequency: med.frequency,
                        nextTime: med.schedule.isNotEmpty
                            ? med.schedule[0]
                            : 'Not scheduled',
                        isTaken: false,
                        onMarkTaken: () {
                          // Handle mark taken
                        },
                        onMarkMissed: () {
                          // Handle mark missed
                        },
                      );
                    },
                  ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    // The backend's MedicationCreate schema requires a start_date that this
    // form did not previously collect (see schemas/medication.py). Default to
    // today and let the user change it.
    DateTime selectedStartDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBackgroundColor,
          title: const Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: frequencyController,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedStartDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${selectedStartDate.year.toString().padLeft(4, '0')}-'
                      '${selectedStartDate.month.toString().padLeft(2, '0')}-'
                      '${selectedStartDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(medicationProvider.notifier).addMedication(
                  name: nameController.text,
                  dosage: dosageController.text,
                  frequency: frequencyController.text,
                  schedule: ['08:00', '20:00'],
                  startDate: selectedStartDate,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
