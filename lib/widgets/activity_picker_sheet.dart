import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../constants/university_activities.dart';
import '../widgets/activity_chip.dart';

class ActivityPickerSheet extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String>) onSave;

  const ActivityPickerSheet({
    super.key,
    required this.initialSelected,
    required this.onSave,
  });

  @override
  State<ActivityPickerSheet> createState() => _ActivityPickerSheetState();
}

class _ActivityPickerSheetState extends State<ActivityPickerSheet> {
  late List<String> _selectedLabels;

  @override
  void initState() {
    super.initState();
    _selectedLabels = List.from(widget.initialSelected);
  }

  void _toggleActivity(String label) {
    setState(() {
      if (_selectedLabels.contains(label)) {
        _selectedLabels.remove(label);
      } else {
        if (_selectedLabels.length < 6) {
          _selectedLabels.add(label);
        } else {
          Get.snackbar(
            'Limit Reached',
            'Select up to 6 activities to keep the vibe elite.',
            backgroundColor: AppColors.secondary.withOpacity(0.9),
            colorText: Colors.black,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT YOUR VIBE',
                      style: AppTextStyles.label(
                        10,
                        color: AppColors.primary,
                        letterSpacing: 3.0,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PICK UP TO 6 ACTIVITIES',
                      style: AppTextStyles.headline(24, weight: FontWeight.w900),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategory('🏆 SPORTS', UniversityActivities.sports),
                    const SizedBox(height: 32),
                    _buildCategory('🎭 SOCIETIES & CLUBS', UniversityActivities.societies),
                    const SizedBox(height: 32),
                    _buildCategory('🎨 INTERESTS & HOBBIES', UniversityActivities.interests),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_selectedLabels);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'CONFIRM SELECTIONS',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<Activity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.label(
            12,
            color: Colors.white24,
            weight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: activities.map((activity) {
            final isSelected = _selectedLabels.contains(activity.label);
            return ActivityChip(
              label: activity.label,
              icon: activity.icon,
              isSelected: isSelected,
              onTap: () => _toggleActivity(activity.label),
            );
          }).toList(),
        ),
      ],
    );
  }
}
