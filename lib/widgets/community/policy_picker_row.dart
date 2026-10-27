// lib/widgets/community/policy_picker_row.dart

import 'package:flutter/material.dart';

import '../../../models/policy_model.dart';
import '../../../data/policy_data.dart';

class PolicyPickerRow extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<PolicyModel> onSelected;

  const PolicyPickerRow({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: PolicyData.policies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final policy = PolicyData.policies[index];
          final isSelected = policy.id == selectedId;
          return _PolicyCard(
            policy: policy,
            isSelected: isSelected,
            onTap: () => onSelected(policy),
          );
        },
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final PolicyModel policy;
  final bool isSelected;
  final VoidCallback onTap;

  const _PolicyCard({
    required this.policy,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : Colors.grey.shade100,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.06 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F766E).withOpacity(0.08)
                    : const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                policy.icon,
                size: 16,
                color: isSelected
                    ? const Color(0xFF0F766E)
                    : const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 8),
            // Policy name
            Text(
              policy.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF0F766E)
                    : const Color(0xFF111827),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Source tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: policy.tagColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                policy.affectedSourceTag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: policy.tagColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}