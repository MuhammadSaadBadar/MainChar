import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/global_top_nav.dart';

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
          CustomScrollView(
            slivers: [
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
          aspectRatio: isMobile ? 4 / 5 : 5 / 6,
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
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        
        // Integrated Header Overlay
        _IntegratedHeader(
          username: userData?['username'] ?? 'User',
          avatarUrl: userData?['avatar_url'],
          isMobile: isMobile,
        ),

        // Desktop Badges
        if (!isMobile) ...[
          Positioned(
            top: 24,
            right: -24,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

class _IntegratedHeader extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final bool isMobile;

  const _IntegratedHeader({
    required this.username,
    this.avatarUrl,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
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
            if (!isMobile) ...[
              const GlobalTopNav(),
            ],
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? Text(
                            username.substring(0, 1).toUpperCase(),
                            style: AppTextStyles.label(12, color: AppColors.primary),
                          )
                        : null,
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

class _MobileLayout extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isRevealHour;
  const _MobileLayout({this.userData, required this.isRevealHour});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (MediaQuery.of(context).size.width < 768)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: GlobalTopNav(),
          ),
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
          flex: 6,
          child: _HeroSection(userData: userData, isRevealHour: isRevealHour),
        ),
        const SizedBox(width: 64),
        Expanded(flex: 5, child: _ContentSection(userData: userData)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : (color ?? AppColors.surfaceContainerHigh).withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isOutlined ? AppColors.onSurfaceVariant.withOpacity(0.5) : (color ?? Colors.transparent).withOpacity(0.5),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label(
          8,
          color: color ?? AppColors.onSurfaceVariant,
          weight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
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
              style: AppTextStyles.headline(100, weight: FontWeight.w900),
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
                  _StatBadge(label: 'UPVOTES', value: '1.2K'),
                  _StatBadge(label: 'AURA', value: '450'),
                  _StatBadge(label: 'STREAK', value: '12', isSecondary: true),
                ],
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label(
              8,
              color: AppColors.onSurfaceVariant,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headline(
              20,
              color: isSecondary ? AppColors.secondary : AppColors.onSurface,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COLLECTIONS',
                style: AppTextStyles.label(
                  12,
                  color: AppColors.secondary,
                  letterSpacing: 4.0,
                  weight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'THE VAULT',
                style: AppTextStyles.headline(32, weight: FontWeight.w900),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.surfaceContainerHighest,
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-${1500000000000 + index}?w=500&q=80'),
                    fit: BoxFit.cover,
                  ),
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
