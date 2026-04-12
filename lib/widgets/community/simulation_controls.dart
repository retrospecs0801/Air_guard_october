// lib/widgets/community/simulation_controls.dart

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../models/policy_model.dart';

class SimulationControls extends StatelessWidget {
  final int selectedDays;
  final SimulationIntensity selectedIntensity;
  final bool isLoading;
  final bool hasPolicy;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<SimulationIntensity> onIntensityChanged;
  final VoidCallback onSimulate;

  const SimulationControls({
    super.key,
    required this.selectedDays,
    required this.selectedIntensity,
    required this.isLoading,
    required this.hasPolicy,
    required this.onDaysChanged,
    required this.onIntensityChanged,
    required this.onSimulate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration row
          Row(
            children: [
              _SectionLabel(label: 'Duration'),
              const Spacer(),
              _SegmentToggle(
                options: const ['30 days', '90 days'],
                values: const [30, 90],
                selected: selectedDays,
                onChanged: onDaysChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Intensity row
          Row(
            children: [
              _SectionLabel(label: 'Enforcement'),
              const SizedBox(width: 12),
              ...SimulationIntensity.values.map((intensity) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _IntensityChip(
                  label: intensity.label,
                  isSelected: selectedIntensity == intensity,
                  onTap: () => onIntensityChanged(intensity),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (hasPolicy && !isLoading) ? onSimulate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    PhosphorIconsBold.play,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Run Simulation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!hasPolicy)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Select a policy above to run simulation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }
}

class _SegmentToggle extends StatelessWidget {
  final List<String> options;
  final List<int> values;
  final int selected;
  final ValueChanged<int> onChanged;

  const _SegmentToggle({
    required this.options,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final isActive = values[i] == selected;
          return GestureDetector(
            onTap: () => onChanged(values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _IntensityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntensityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  Color get _selectedColor {
    switch (label) {
      case 'Low':
        return const Color(0xFF22C55E);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'High':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF0F766E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? _selectedColor : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}