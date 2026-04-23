import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCompact;

  const ActivityChip({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: isCompact ? 14 : 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label(
                  isCompact ? 10 : 12,
                  color: isSelected ? Colors.black : AppColors.onSurfaceVariant,
                  weight: isSelected ? FontWeight.bold : FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
