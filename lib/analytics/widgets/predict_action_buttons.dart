// lib/analytics/widgets/predict_action_buttons.dart
import 'package:flutter/material.dart';
import '../models/analytics_data.dart';

class PredictActionButtons extends StatelessWidget {
  final bool isPredicting;
  final bool isSimulating;
  final bool canSimulate; // false if 0 precautions selected
  final VoidCallback onPredict;
  final VoidCallback onSimulate;

  const PredictActionButtons({
    Key? key,
    required this.isPredicting,
    required this.isSimulating,
    required this.canSimulate,
    required this.onPredict,
    required this.onSimulate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Predict button ────────────────────────────────
        Expanded(
          child: _ActionButton(
            label: isPredicting ? 'Predicted' : 'Predict',
            icon: Icons.auto_graph_rounded,
            isActive: isPredicting,
            activeColor: const Color(0xFF4F46E5), // indigo
            onTap: onPredict,
          ),
        ),
        const SizedBox(width: 10),

        // ── Simulate button ───────────────────────────────
        Expanded(
          child: _ActionButton(
            label: isSimulating ? 'Simulated' : 'Simulate',
            icon: Icons.shield_outlined,
            isActive: isSimulating,
            activeColor: AppColors.teal,
            isDisabled: !isPredicting || !canSimulate,
            onTap: (!isPredicting || !canSimulate) ? null : onSimulate,
            disabledHint: !canSimulate
                ? 'Select at least one measure'
                : 'Run Predict first',
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDisabled;
  final Color activeColor;
  final VoidCallback? onTap;
  final String? disabledHint;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    this.isDisabled = false,
    this.onTap,
    this.disabledHint,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    Color borderColor;

    if (isActive) {
      bgColor     = activeColor;
      fgColor     = Colors.white;
      borderColor = activeColor;
    } else if (isDisabled) {
      bgColor     = AppColors.divider;
      fgColor     = AppColors.textMuted;
      borderColor = AppColors.divider;
    } else {
      bgColor     = AppColors.cardBg;
      fgColor     = AppColors.textPrimary;
      borderColor = AppColors.borderLight;
    }

    return GestureDetector(
      onTap: isDisabled
          ? () {
        if (disabledHint != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(disabledHint!),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
          : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: activeColor.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.check_circle_outline : icon,
              size: 16,
              color: fgColor,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fgColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}