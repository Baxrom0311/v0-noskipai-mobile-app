import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/config/app_theme.dart';
import 'package:noskipai/providers/services_provider.dart';
import 'package:noskipai/widgets/glassmorphic_container.dart';

class SafetySignalsScreen extends ConsumerStatefulWidget {
  const SafetySignalsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SafetySignalsScreen> createState() => _SafetySignalsScreenState();
}

class _SafetySignalsScreenState extends ConsumerState<SafetySignalsScreen> {
  List<dynamic> _signals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSignals();
  }

  Future<void> _loadSignals() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      _signals = await api.getMySafetySignals();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Signals')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _signals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, size: 64, color: AppTheme.successColor.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('No safety signals', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Your medications are safe', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSignals,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _signals.length,
                    itemBuilder: (context, index) {
                      final signal = _signals[index] as Map<String, dynamic>;
                      return _buildSignalCard(signal);
                    },
                  ),
                ),
    );
  }

  Widget _buildSignalCard(Map<String, dynamic> signal) {
    final severity = signal['severity'] as String? ?? 'info';
    final title = signal['title'] as String? ?? '';
    final status = signal['status'] as String? ?? 'active';
    final color = _severityColor(severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        blur: 6,
        opacity: 0.1,
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'reviewed' ? AppTheme.successColor.withOpacity(0.15) : color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: status == 'reviewed' ? AppTheme.successColor : color),
                  ),
                ),
              ],
            ),
            if (signal['doctor_action'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.medical_services, size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text('Doctor: ${signal['doctor_action']}', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }
}
