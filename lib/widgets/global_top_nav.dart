import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class GlobalTopNav extends StatelessWidget {
  const GlobalTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavLink(
          label: 'Look Around',
          active: currentRoute == AppRoutes.EXPLORE,
          onTap: () => _navigate(AppRoutes.EXPLORE),
        ),
        const SizedBox(width: 32),
        _NavLink(
          label: 'Arena',
          active: currentRoute == AppRoutes.ARENA,
          onTap: () => _navigate(AppRoutes.ARENA),
        ),
        const SizedBox(width: 32),
        _NavLink(
          label: 'Leaderboard',
          active: currentRoute == AppRoutes.LEADERBOARD,
          onTap: () => _navigate(AppRoutes.LEADERBOARD),
        ),

        const SizedBox(width: 32),
        _NavLink(
          label: 'My Profile',
          active: currentRoute == AppRoutes.PROFILE,
          onTap: () => _navigate(AppRoutes.PROFILE),
        ),
      ],
    );
  }

  void _navigate(String route) {
    if (Get.currentRoute != route) {
      Get.offNamed(route);
    }
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(
              10,
              color: active ? AppColors.secondary : AppColors.onSurfaceVariant,
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: AppColors.secondary,
            ),
        ],
      ),
    );
  }
}
