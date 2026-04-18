import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/demo_header.dart';
import '../../widgets/activity_chip.dart';
import '../../constants/university_activities.dart';
import 'demo_nav.dart';

class DemoProfileScreen extends StatefulWidget {
  const DemoProfileScreen({super.key});

  @override
  State<DemoProfileScreen> createState() => _DemoProfileScreenState();
}

class _DemoProfileScreenState extends State<DemoProfileScreen> {
  // Hardcoded dummy data for the demo tour
  final Map<String, dynamic> _userData = {
    'username': 'DemoUser Alpha',
    'avatar_url': 'assets/image1.webp',
    'vibe_tags': ['Sports', 'Music', 'Tech'],
    'level': 24,
    'hype': 8240,
    'rank': 1,
  };

  final List<Map<String, dynamic>> _memories = [
    {
      'id': 1,
      'image_url': 'assets/memory1.webp',
      'description': 'First day at campus! 🎒',
    },
    {
      'id': 2,
      'image_url': 'assets/memory2.webp',
      'description': 'Late night study session. ☕',
    },
    {
      'id': 3,
      'image_url': 'assets/memory3.webp',
      'description': 'UOL Festival 2024 vibes. ✨',
    },
  ];

  void _showJoinSnackbar(String feature) {
    Get.snackbar(
      'Join the Platform',
      'Register to $feature your own profile!',
      backgroundColor: AppColors.secondary,
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );
  }

  void _handleLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'EXIT TOUR',
          style: AppTextStyles.label(
            18,
            weight: FontWeight.w900,
            color: AppColors.secondary,
          ),
        ),
        content: Text(
          'Are you sure you want to end your guest session?',
          style: AppTextStyles.body(16, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'CANCEL',
              style: AppTextStyles.label(
                12,
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              elevation: 0,
            ),
            child: Text(
              'EXIT',
              style: AppTextStyles.label(
                12,
                weight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      barrierColor: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundImage(),
          const _BackgroundBlobs(),
          const _GrainOverlay(),
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: DemoHeader(title: 'CAMPUS VIBE')),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  left: 24,
                  right: 24,
                  bottom: 48,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 900) {
                            return _DesktopLayout(
                              userData: _userData,
                              onAction: _showJoinSnackbar,
                              onLogout: _handleLogout,
                            );
                          } else {
                            return _MobileLayout(
                              userData: _userData,
                              onAction: _showJoinSnackbar,
                              onLogout: _handleLogout,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _MemoriesSection(
                  memories: _memories,
                  onAction: _showJoinSnackbar,
                ),
              ),
              const SliverToBoxAdapter(child: _Footer()),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/profile_background.webp', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

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
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAT_w_ZeV94lSMmj6dQo2D_WDwLvvvFmQzKj7frQuQoMpliedmi0sooCJZUPkZCMJVLdzhig9_Buf2LETpdc7fClZ8Gj5iadPNSWLsOZQF5rnDALFW0hXiKc8EmxRNU0BsM9fWqmkKS75PxkfyZfZVnw0nxoysOHLkqUEec_9dXUKNu_sTJrE1A-ndyzf_36PQkS-eZkesf1KLP0GiXh9m525ZmPtlCOMTniwXxndxDmBnLcadAC59OYpo1czOWZGzo0YM0eKyseio',
              ),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isMobile;
  final Function(String) onAction;

  const _HeroSection({
    this.userData,
    this.isMobile = false,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: isMobile ? 240 : 300,
            height: isMobile ? 240 : 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.asset(
              userData?['avatar_url'] ?? 'assets/image1.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => onAction('edit'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function(String) onAction;
  final VoidCallback onLogout;

  const _MobileLayout({
    required this.userData,
    required this.onAction,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (MediaQuery.of(context).size.width < 768)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Center(child: DemoNav()),
          ),
        _HeroSection(userData: userData, isMobile: true, onAction: onAction),
        const SizedBox(height: 48),
        _ContentSection(
          userData: userData,
          onAction: onAction,
          onLogout: onLogout,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function(String) onAction;
  final VoidCallback onLogout;

  const _DesktopLayout({
    required this.userData,
    required this.onAction,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _HeroSection(userData: userData, onAction: onAction),
        ),
        const SizedBox(width: 64),
        Expanded(
          flex: 5,
          child: _ContentSection(
            userData: userData,
            onAction: onAction,
            onLogout: onLogout,
            isDesktop: true,
          ),
        ),
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function(String) onAction;
  final VoidCallback onLogout;
  final bool isDesktop;

  const _ContentSection({
    required this.userData,
    required this.onAction,
    required this.onLogout,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              userData['username'].toString().toUpperCase(),
              style: AppTextStyles.headline(100, weight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 22),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE ORIGIN STORY',
                    style: AppTextStyles.label(
                      10,
                      color: AppColors.primary,
                      letterSpacing: 3.0,
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: (userData['vibe_tags'] as List).map((tag) {
                      final activity = UniversityActivities.fromLabel(
                        tag.toString(),
                      );
                      return ActivityChip(
                        label: tag.toString(),
                        icon: activity?.icon ?? '✨',
                        isCompact: true,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onAction('VOTE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 20,
                        shadowColor: AppColors.secondary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.electric_bolt_rounded, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'VOTE FOR THIS USER',
                            style: AppTextStyles.label(
                              12,
                              color: Colors.black,
                              weight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatBadge(
                        label: 'TOTAL VOTES',
                        value: '🔥 ${userData['hype']}',
                      ),
                      _StatActionBadge(
                        label: 'CAMPUS RANK',
                        value: '#${userData['rank']}',
                        onTap: () => onAction('RANK'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onLogout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.redAccent.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        backgroundColor: Colors.redAccent.withOpacity(0.03),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'EXIT TOUR',
                            style: AppTextStyles.label(
                              14,
                              color: Colors.white.withOpacity(0.8),
                              weight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isDesktop) ...[
          const SizedBox(height: 24),
          Text(
            userData['username'].toString().toUpperCase(),
            style: AppTextStyles.headline(40, weight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isSecondary;

  const _StatBadge({
    required this.label,
    required this.value,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label(
              8,
              color: AppColors.onSurfaceVariant.withOpacity(0.6),
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headline(
              24,
              color: isSecondary ? AppColors.secondary : Colors.white,
              weight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatActionBadge extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatActionBadge({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.label(
                8,
                color: AppColors.secondary,
                letterSpacing: 2.0,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.label(
                    14,
                    color: Colors.white,
                    weight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> memories;
  final Function(String) onAction;

  const _MemoriesSection({required this.memories, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEMORIES AT UOL',
                style: AppTextStyles.label(
                  16,
                  weight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
              IconButton(
                onPressed: () => onAction('upload'),
                icon: const Icon(
                  Icons.add_a_photo_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 420,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return Container(
                width: 320,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.surfaceContainerHigh,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(memory['image_url'], fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory['description'],
                            style: AppTextStyles.body(
                              16,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JUST NOW',
                            style: AppTextStyles.label(
                              10,
                              color: AppColors.primary,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Column(
        children: [
          Text(
            'CAMPUS VIBE',
            style: AppTextStyles.label(
              12,
              color: AppColors.secondary,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Support'.toUpperCase(),
                style: AppTextStyles.label(10, letterSpacing: 2.0),
              ),
              const SizedBox(width: 32),
              Text(
                'Privacy'.toUpperCase(),
                style: AppTextStyles.label(10, letterSpacing: 2.0),
              ),
              const SizedBox(width: 32),
              Text(
                'Terms'.toUpperCase(),
                style: AppTextStyles.label(10, letterSpacing: 2.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, width: 80, color: AppColors.surfaceContainer),
          const SizedBox(height: 24),
          Text(
            '© 2024 MAIN CHARACTER ENERGY. .EDU VERIFIED.',
            style: AppTextStyles.label(
              10,
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
