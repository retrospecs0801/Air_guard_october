import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme_extension.dart';
import '../models/recovery_task.dart';

IconData recoveryTaskIcon(RecoveryTask task) {
  return switch (task.id) {
    'breathing_1' || 'breathing_3' || 'breathing_4' => Icons.air,
    'breathing_2' => Icons.spa_outlined,
    'hydration' => Icons.water_drop_outlined,
    'stretch_1' => Icons.accessibility_new,
    'mask' => Icons.masks_outlined,
    'diet_1' || 'diet_2' => Icons.restaurant_outlined,
    'doctor' => Icons.medical_services_outlined,
    'avoid_exposure' => Icons.home_outlined,
    _ => switch (task.type) {
      TaskType.breathing => Icons.air,
      TaskType.hydration => Icons.water_drop_outlined,
      TaskType.stretch => Icons.accessibility_new,
      TaskType.mask => Icons.masks_outlined,
      TaskType.diet => Icons.restaurant_outlined,
      TaskType.doctorCTA => Icons.medical_services_outlined,
    },
  };
}

class RecoveryTaskIconTile extends StatelessWidget {
  final RecoveryTask task;

  const RecoveryTaskIconTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: task.title,
      image: true,
      child: SizedBox.square(
        dimension: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.app.brandSoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            recoveryTaskIcon(task),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
