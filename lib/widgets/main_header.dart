import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'global_top_nav.dart';

class MainHeader extends StatelessWidget {
  final String title;
  final String? avatarUrl;
  final String? username;
  final bool showSecondaryAction; // For the flame icon or similar

  const MainHeader({
    super.key,
    required this.title,
    this.avatarUrl,
    this.username,
    this.showSecondaryAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
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
                  if (!isMobile) ...[const GlobalTopNav()],
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          image: avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: avatarUrl == null
                            ? Center(
                                child: Text(
                                  (username ?? 'U')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: AppTextStyles.label(
                                    12,
                                    color: AppColors.primary,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
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
