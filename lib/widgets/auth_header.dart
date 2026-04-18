import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class AuthHeader extends StatelessWidget {
  final String activeLink;

  const AuthHeader({
    super.key,
    required this.activeLink,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.black.withOpacity(0.6),
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'CAMPUS VIBE',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 400 ? 24 : 18,
                  color: AppColors.secondary,
                  italic: true,
                  weight: FontWeight.w900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderLink(
                  label: 'Register',
                  active: activeLink == 'Register',
                  onTap: () => Get.toNamed(AppRoutes.REGISTER),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 400 ? 32 : 16,
                ),
                _HeaderLink(
                  label: 'Login',
                  active: activeLink == 'Login',
                  onTap: () => Get.toNamed(AppRoutes.LOGIN),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.white10, height: 0.5),
      ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _HeaderLink({
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(
              12,
              color: active ? AppColors.secondary : AppColors.onSurfaceVariant,
              letterSpacing: 2.0,
              weight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: AppColors.secondary,
            ),
        ],
      ),
    );
  }
}
