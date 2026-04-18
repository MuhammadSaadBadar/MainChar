import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../screens/demo/demo_nav.dart';

class DemoHeader extends StatelessWidget {
  final String title;

  const DemoHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 31, 23, 23).withOpacity(0.6),
            border: const Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.headline(
                      24,
                      color: AppColors.secondary,
                      italic: true,
                      weight: FontWeight.w900,
                    ),
                  ),
                  if (!isMobile) ...[const DemoNav()],
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white24,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
