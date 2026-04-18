import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your university email.',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      Get.snackbar(
        'Success',
        'Recovery email sent! Check your inbox.',
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        colorText: AppColors.secondary,
      );
      // Optional: Delay and navigate back to login
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundDecor(),
          const _GrainOverlay(),
          const _TopAppBar(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: _EditorialSection()),
                              const SizedBox(width: 80),
                              Expanded(
                                child: _RecoveryCard(
                                  controller: _emailController,
                                  onReset: _handleReset,
                                  isLoading: _isLoading,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _EditorialSection(),
                              const SizedBox(height: 64),
                              _RecoveryCard(
                                controller: _emailController,
                                onReset: _handleReset,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CAMPUS',
                  style: AppTextStyles.headline(
                    24,
                    color: AppColors.primary,
                    italic: true,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.help_outline,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialSection extends StatelessWidget {
  const _EditorialSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCESS RESTORATION',
          style: AppTextStyles.label(
            12,
            color: AppColors.secondary,
            weight: FontWeight.bold,
            letterSpacing: 4.0,
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: AppTextStyles.headline(
              MediaQuery.of(context).size.width > 768 ? 84 : 48,
              weight: FontWeight.w900,
              italic: true,
            ),
            children: [
              const TextSpan(text: 'LOST YOUR ACCOUNT?\n'),
              TextSpan(
                text: 'NO WORRIES G',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 768 ? 84 : 48,
                  weight: FontWeight.w900,
                  color: AppColors.primary,
                  italic: true,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),
        Row(
          children: [
            const _AvatarStack(),
            const SizedBox(width: 24),
            Text(
              'JOIN 10K+ MUSES',
              style: AppTextStyles.label(
                10,
                color: AppColors.onSurfaceVariant,
                weight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onReset;
  final bool isLoading;

  const _RecoveryCard({
    required this.controller,
    required this.onReset,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF262626).withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Recovery',
                style: AppTextStyles.headline(28, weight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify your identity to reset your password.',
                style: AppTextStyles.body(
                  14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              _RecoveryForm(
                controller: controller,
                onReset: onReset,
                isLoading: isLoading,
              ),
              const SizedBox(height: 48),
              Center(
                child: TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(
                    'BACK TO LOGIN',
                    style: AppTextStyles.label(
                      12,
                      color: AppColors.onSurfaceVariant,
                      weight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoveryForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onReset;
  final bool isLoading;

  const _RecoveryForm({
    required this.controller,
    required this.onReset,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNIVERSITY EMAIL (.EDU ONLY)',
          style: AppTextStyles.label(
            10,
            color: AppColors.primary,
            weight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.body(14),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: AppColors.onSurfaceVariant,
              ),
              hintText: 'you@university.edu',
              hintStyle: AppTextStyles.body(14, color: AppColors.outline),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: isLoading ? null : onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 20,
              shadowColor: AppColors.secondary.withOpacity(0.4),
            ),
            child: isLoading
                ? const Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SEND RECOVERY CODE',
                        style: AppTextStyles.label(
                          14,
                          color: Colors.black,
                          weight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 100,
      child: Stack(
        children: [
          _AvatarItem(
            index: 0,
            url:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAoaAxJ0oTniKANKtJB4jCcbQkTRo5vYOANja1x7dKyQxzj4xSfz2o6Hir6NAXbAyKrUNHnrsOmO2gTgqXm179Vo8r79z1tsK6kVRT8Nu-cUOh4r8QYTSmEWv_iZEqY2xPmi6tDywf6QGt_y2LgfjDd_x52DvZ0lp80GQ3Vbg7NeUDe4xLMYrUOWN6NaquwTCBDGA1PTqp-nHuhqUtCdqJK1BLIl6P1v9FzvV2IdBSlhLJIQ1t7TdawRMRzcOCd_b77Y0WXiUbBSFE',
          ),
          Positioned(
            left: 20,
            child: _AvatarItem(
              index: 1,
              url:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBvMRDogPajTHUUGuYKyul0byQRj-KmLME2zl2EibJr0DibLHQlLIkuqZBuyM0aC0UXpdvIu1SLUZyAH_6c87uGZlDLe0j0Eo8mXg11H3LhIPqAMIaO-rc4tDJ_NBU46r83fPRw_1ux7SmcFXNKMAsF-i_h7HALe2WDCGt23HSh727zarQzbPMdgPhn1DzlLAgcsxMNdL17xJmgiKbMWBYngbPV6UbSLygYBXLxe0mxvuXXvA_mgRvjrq0PRMDKKrRHTht8plyr-D8',
            ),
          ),
          Positioned(
            left: 40,
            child: _AvatarItem(
              index: 2,
              url:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuArtXE-bHbo5SAOfyqW4RMqgVW8logp0yk19v4NSkq8OI8bUkBMkZ9QQe26J80_3t8qa0YS0ZGUFk5QFEEDeojhdLUvB-dRCb5bPVqVfKZois_BDS4LjQXsV5FRpF-hXKsdmmycoPIqebSboM4oTDrtckwmKI9ZzSUI1kI51Tt8CrvprTLIcHBpIp2Oie7wwoc-ARXgFRhiRa4n4PzUz8R7tkT4A7N2iIhlI_3ghcG8kaW023IYegPcfmRxN7TUrmeZoAp6SzRxDio',
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  final int index;
  final String url;
  const _AvatarItem({required this.index, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.12),
            ),
          ).withBlur(120),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.08),
            ),
          ).withBlur(120),
        ),
      ],
    );
  }
}

extension _BlurExtension on Widget {
  Widget withBlur(double sigma) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    child: this,
  );
}

class _GrainOverlay extends StatelessWidget {
  const _GrainOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDSyDbPME4_ep428SirfZ3OwGKRT0B4qeECtW0qXAq7VsRGjhQhWdOjjrbY_svsjvmjPC9SbZel9Di1PHhuQM187_0pvoUo8OZjp-UISDnZjyTjl9WBZCAEgUUDKYT5kLcY7hjxYXuUDEdz7uNn0lUlubl1I5yKiBIWwtAdfCNrF7gDZdRi63emXPq4QXLLIC3hjpqTAs0R2B-yfO65pySP75MaQL9wbT8LCSVIH8oSwHY9QIyGceNqZ-EYj3d7Z-nla72IFKd6tCQ',
              ),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      ),
    );
  }
}
