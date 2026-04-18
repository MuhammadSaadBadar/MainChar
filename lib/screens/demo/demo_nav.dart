import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class DemoNav extends StatelessWidget {
  const DemoNav({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavLink(
            label: 'Look Around',
            active: currentRoute == AppRoutes.DEMO_EXPLORE,
            onTap: () => _navigate(AppRoutes.DEMO_EXPLORE),
          ),
          const SizedBox(width: 32),
          _NavLink(
            label: 'Arena',
            active: currentRoute == AppRoutes.DEMO_ARENA,
            onTap: () => _navigate(AppRoutes.DEMO_ARENA),
          ),
          const SizedBox(width: 32),
          _NavLink(
            label: 'Leaderboard',
            active: currentRoute == AppRoutes.DEMO_LEADERBOARD,
            onTap: () => _navigate(AppRoutes.DEMO_LEADERBOARD),
          ),
          const SizedBox(width: 32),
          _NavLink(
            label: 'My Profile',
            active: currentRoute == AppRoutes.DEMO_PROFILE,
            onTap: () => _navigate(AppRoutes.DEMO_PROFILE),
          ),
          const SizedBox(width: 48),
          // Sign In / Register CTA
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.REGISTER),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'JOIN PLATFORM',
              style: AppTextStyles.label(
                12,
                weight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
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
