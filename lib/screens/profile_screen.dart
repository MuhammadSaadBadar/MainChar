import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isRevealHour = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkRevealStatus();
  }

  void _checkRevealStatus() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _isRevealHour = (now.day == lastDay.day && now.hour == 20);
    });
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _userData = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          const _GrainOverlay(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _StickyNav(
                  avatarUrl: _userData?['avatar_url'],
                  username: _userData?['username'],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
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
                                isRevealHour: _isRevealHour,
                              );
                            } else {
                              return _MobileLayout(
                                userData: _userData,
                                isRevealHour: _isRevealHour,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _GallerySection()),
                const SliverToBoxAdapter(child: _Footer()),
              ],
            ),
          ),
          // Mobile Bottom Nav
          if (MediaQuery.of(context).size.width < 900) const _MobileBottomNav(),
        ],
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

class _StickyNav extends StatelessWidget {
  final String? avatarUrl;
  final String? username;
  const _StickyNav({this.avatarUrl, this.username});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final initials = (username ?? 'U').substring(0, 1).toUpperCase();
    return SliverAppBar(
      backgroundColor: Colors.black.withOpacity(0.6),
      floating: true,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CAMPUS VIBE',
              style: AppTextStyles.headline(
                24,
                color: AppColors.secondary,
                italic: true,
              ),
            ),
            if (MediaQuery.of(context).size.width > 768)
              Row(
                children: [
                  _NavLink(label: 'Look Around'),
                  const SizedBox(width: 32),
                  _NavLink(label: 'Leaderboard'),
                  const SizedBox(width: 32),
                  _NavLink(label: 'My Profile', active: true),
                ],
              ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: hasAvatar
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: !hasAvatar
                          ? Text(
                              initials,
                              style: AppTextStyles.label(
                                12,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  const _NavLink({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            width: 20,
            color: AppColors.secondary,
          ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isRevealHour;
  const _MobileLayout({this.userData, required this.isRevealHour});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroSection(
          userData: userData,
          isRevealHour: isRevealHour,
          isMobile: true,
        ),
        const SizedBox(height: 48),
        _ContentSection(userData: userData),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isRevealHour;
  const _DesktopLayout({this.userData, required this.isRevealHour});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _HeroSection(userData: userData, isRevealHour: isRevealHour),
        ),
        const SizedBox(width: 64),
        Expanded(flex: 5, child: _ContentSection(userData: userData)),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isRevealHour;
  final bool isMobile;
  const _HeroSection({
    this.userData,
    required this.isRevealHour,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        userData?['avatar_url'] != null &&
        userData!['avatar_url'].toString().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Image
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.surfaceContainerHigh,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(userData!['avatar_url']),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: hasAvatar
                ? (isMobile ? _buildMobileOverlay() : null)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 80,
                          color: Colors.white10,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'STYLE YOUR PROFILE',
                          style: AppTextStyles.label(
                            12,
                            color: Colors.white24,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        // Desktop Badges
        if (!isMobile) ...[
          Positioned(
            top: -20,
            right: -20,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Text(
                  'MAIN CHARACTER',
                  style: AppTextStyles.label(
                    14,
                    color: Colors.black,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: -32,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HYPE LEVEL',
                          style: AppTextStyles.label(
                            10,
                            letterSpacing: 2.0,
                            weight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HIGH',
                          style: AppTextStyles.headline(
                            28,
                            color: AppColors.secondary,
                            italic: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.85,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Tag(label: 'Vibe: Legend', color: AppColors.primary),
              const SizedBox(width: 8),
              _Tag(label: 'Featured Profile', color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            (userData?['username'] ?? 'User').toUpperCase(),
            style: AppTextStyles.headline(48, weight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const _ContentSection({this.userData});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          const Row(
            children: [
              _Tag(label: 'Design', isOutlined: true),
              SizedBox(width: 12),
              _Tag(label: 'Senior', isOutlined: true),
            ],
          ),
          const SizedBox(height: 24),
          FittedBox(
            child: Text(
              (userData?['username'] ?? 'User').toUpperCase(),
              style: AppTextStyles.headline(120, weight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 32),
        ],
        // Bio Section
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
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
              const SizedBox(height: 16),
              Text(
                userData?['bio'] ?? 'No bio set yet.',
                style: AppTextStyles.body(
                  18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _VibeTag(label: 'Chill', color: AppColors.primary),
                  _VibeTag(label: 'Icon', color: AppColors.secondary),
                  _VibeTag(label: 'Legend', color: AppColors.tertiary),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Academic Info
        const _InfoCard(
          icon: Icons.school_rounded,
          label: 'UNIVERSITY',
          value: 'Metropolis Institute of Art',
          color: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.palette_rounded,
          label: 'MAJOR',
          value: 'Experimental Digital Design',
          color: AppColors.primary,
        ),
        const SizedBox(height: 32),
        // Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.to(() => const EditProfileScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 20,
              shadowColor: AppColors.secondary.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EDIT PROFILE',
                  style: AppTextStyles.headline(
                    24,
                    color: Colors.black,
                    weight: FontWeight.w900,
                    italic: true,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.edit_rounded, size: 28),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'LAST UPDATED 2 DAYS AGO',
            style: AppTextStyles.label(
              10,
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isOutlined;
  const _Tag({required this.label, this.color, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isOutlined
            ? AppColors.surfaceContainerHigh
            : (color?.withOpacity(0.2) ?? Colors.white10),
        borderRadius: BorderRadius.circular(100),
        border: isOutlined ? Border.all(color: Colors.white10) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label(
          10,
          color: isOutlined
              ? AppColors.onSurfaceVariant
              : (color ?? Colors.white),
          letterSpacing: 2.0,
          weight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VibeTag extends StatelessWidget {
  final String label;
  final Color color;
  const _VibeTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.body(14, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label(
                    10,
                    letterSpacing: 2.0,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection();

  @override
  Widget build(BuildContext context) {
    final images = [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB6iz1P8rhg9V2aygYf7QPEWhLw0nbBS7zOh3Xci9O8DP-KBYkctDY442Z1V-8HDKh_Gpk_klWmm7wfLcfRvhnW3NrxJHhmJIEg4URqUcTGK7wOPUqMN3hBUZEcsTsbWmg__nWAmETzcnZYkYm3FaaqZpPkGJvjyaGXO5uRVYvRwq-nRbJmOw1TcVkn4kuQxGDw83NfSY7BhE1yDA64Gv3Ld2nGPty5F1cB4u6cuVaUuECeeqhr3vMr0qgQYs2xvoleLqw_7cRj9IE',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBe2RBq2twgLoNrl0huScoOr3YdzVTmP3Y7s873OPNFJeuZ1j_DMrJpRXx1GaoudBep-wvzGd6IYGarYk-1vtKY5S9q95iUyyUAmdJESA2YhooBxh0Y23kEn13qcP20s0u_ZhMi3D4bUj6e26KmzdYA21vWhp1Y1dD9OdAqbdAU_hP8Z4Y-q2Y72xGL5aP4iKozkURAVD_bIeNHZlt6z8-qijT9Vhq0sgChea08U-0VE9gtTSNjhs0SMINGypKgH33yUNflR-kpu8A',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDecDnNQnpXmedOFjyRo2rgyfbnXwFdOr1qAF_rBkShCibQbKgJs3rG9y9O-k0WO4Gx7CZ1W4KoKccRkQRLXcWzxzVTvRcEgpNQl_tT-gsB5K-MjPl_6CfUMUvGOuSzHLrZnYqWzWKNkA2C2XNb29N0b0q_-Zj-jkfrxQKkReLEmKXq5ETDfkQoZJbXfgftjlWKfMZWN-ioZYqL5LK8306OKSAdDYFdDNKdpB0jb6UKHrkcJ1N8d0DA9vKrho_dVbMjcaRov3HA97w',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAGWkMIyW-tZ3v71bPRhCRib3S7bhHljOCrD-8A9hvhaKJCptzdfWQdar0V0y9jgy_7de4N_8k4vDb2NJc98ZlcpZcMICngOd4SmTJ--BreUNRTDjep0XvGP3bmG5r9Iu41_5btDDeusHkJRmo1FkUMbE_uBPx3F2sF6Q30FoZPsWguHzIhtWYcgIfvK4fHJORbCSRtM5UBueBZdEDz2LL5LR9utg0WAMFUug7EB0dbl_1QJEoWnUJnNrMIh_9M3sP3vinIYDIg-UI',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'RECENT VIBE CHECK',
                style: AppTextStyles.headline(32, weight: FontWeight.w900),
              ),
              const SizedBox(width: 24),
              Expanded(child: Container(height: 1, color: Colors.white12)),
            ],
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Transform.translate(
                offset: Offset(
                  0,
                  (index % 2 != 0 && MediaQuery.of(context).size.width > 600)
                      ? 48
                      : 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              _FooterLink(label: 'Support'),
              const SizedBox(width: 32),
              _FooterLink(label: 'Privacy'),
              const SizedBox(width: 32),
              _FooterLink(label: 'Terms'),
            ],
          ),
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

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.label(
        10,
        letterSpacing: 2.0,
        weight: FontWeight.bold,
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIcon(
                    icon: Icons.electric_bolt_rounded,
                    label: 'QUICK VOTE',
                  ),
                  _NavIcon(icon: Icons.search_rounded, label: 'SEARCH'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.label(
            8,
            letterSpacing: 1.5,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
