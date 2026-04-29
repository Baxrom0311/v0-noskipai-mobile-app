import 'package:flutter/material.dart';
import 'package:noskipai/config/app_theme.dart';

class MedicationTile extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final String nextTime;
  final bool isTaken;
  final VoidCallback onMarkTaken;
  final VoidCallback onMarkMissed;

  const MedicationTile({
    Key? key,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.nextTime,
    required this.isTaken,
    required this.onMarkTaken,
    required this.onMarkMissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTaken ? AppTheme.primaryColor : AppTheme.borderColor,
          width: 1.5,
        ),
        boxShadow: isTaken
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : AppTheme.borderColor,
            ),
            child: Icon(
              Icons.medication,
              color: isTaken ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                    color: isTaken
                        ? AppTheme.textSecondaryColor
                        : AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dosage • $frequency',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Next: $nextTime',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Mark Taken'),
                onTap: onMarkTaken,
              ),
              PopupMenuItem(
                child: const Text('Mark Missed'),
                onTap: onMarkMissed,
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
