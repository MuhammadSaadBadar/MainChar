import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_header.dart';
import 'demo_nav.dart';

class DemoLeaderboardScreen extends StatelessWidget {
  const DemoLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          const _GrainOverlay(),
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: DemoHeader(title: 'CAMPUS VIBE'),
              ),
              if (MediaQuery.of(context).size.width < 768)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: DemoNav()),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          const _CountdownSection(),
                          const SizedBox(height: 64),
                          _Podium(
                            rank1: {'username': 'DemoUser Alpha', 'avatar_url': 'assets/image1.webp'},
                            rank2: {'username': 'DemoUser Beta', 'avatar_url': 'assets/image2.webp'},
                            rank3: {'username': 'DemoUser Gamma', 'avatar_url': 'assets/image3.webp'},
                          ),
                          const SizedBox(height: 80),
                          _ChallengerList(
                            challengers: [
                              {'username': 'DemoUser Delta', 'avatar_url': 'assets/image4.webp'},
                              {'username': 'DemoUser Epsilon', 'avatar_url': 'assets/image5.webp'},
                            ],
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownSection extends StatelessWidget {
  const _CountdownSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            border: Border.all(color: AppColors.onSurfaceVariant.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'DEMO MODE',
            style: AppTextStyles.label(10, color: AppColors.secondary, weight: FontWeight.bold, letterSpacing: 2.0),
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'The Reveal in ',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 768 ? 84 : (MediaQuery.of(context).size.width > 400 ? 56 : 40),
                  weight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: '7 Days',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 768 ? 84 : (MediaQuery.of(context).size.width > 400 ? 56 : 40),
                  weight: FontWeight.w900,
                  color: AppColors.primary,
                  italic: true,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 800.ms),
        const SizedBox(height: 16),
        Text(
          'MAIN CHARACTER SEASON 01 • TOP 50 QUALIFY',
          style: AppTextStyles.label(12, color: AppColors.onSurfaceVariant, weight: FontWeight.bold, letterSpacing: 3.0),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final Map<String, dynamic> rank1;
  final Map<String, dynamic> rank2;
  final Map<String, dynamic> rank3;

  const _Podium({required this.rank1, required this.rank2, required this.rank3});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: isMobile
            ? Column(
                children: [
                  _PodiumItem(rank: 1, profile: rank1),
                  Padding(padding: const EdgeInsets.only(top: 32), child: _PodiumItem(rank: 2, profile: rank2)),
                  Padding(padding: const EdgeInsets.only(top: 32), child: _PodiumItem(rank: 3, profile: rank3)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _PodiumItem(rank: 2, profile: rank2).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0)),
                  const SizedBox(width: 32),
                  Expanded(child: _PodiumItem(rank: 1, profile: rank1).animate().fadeIn().slideY(begin: 0.2, end: 0)),
                  const SizedBox(width: 32),
                  Expanded(child: _PodiumItem(rank: 3, profile: rank3).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0)),
                ],
              ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> profile;

  const _PodiumItem({required this.rank, required this.profile});

  Color get _rankColor => rank == 1 ? AppColors.secondary : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(rank == 1 ? 40.0 : 32.0),
          decoration: BoxDecoration(
            color: rank == 1 ? AppColors.surfaceContainer : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: rank == 1 ? AppColors.secondary.withOpacity(0.2) : Colors.white10),
            boxShadow: rank == 1 ? [BoxShadow(color: AppColors.secondary.withOpacity(0.1), blurRadius: 50, offset: const Offset(0, 20))] : null,
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _Avatar(url: profile['avatar_url'], color: _rankColor, size: rank == 1 ? (MediaQuery.of(context).size.width > 400 ? 160.0 : 120.0) : (MediaQuery.of(context).size.width > 400 ? 120.0 : 90.0)),
              const SizedBox(height: 24),
              Text(
                profile['username'].toUpperCase(),
                style: AppTextStyles.headline(
                  rank == 1 ? (MediaQuery.of(context).size.width > 400 ? 28 : 20) : (MediaQuery.of(context).size.width > 400 ? 20 : 16),
                  weight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: _rankColor),
              child: Text('#$rank', style: AppTextStyles.headline(24, color: Colors.black, weight: FontWeight.w900, italic: true)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final Color color;
  final double size;

  const _Avatar({required this.url, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: Image.asset(
          url,
          fit: BoxFit.cover,
          cacheWidth: size.toInt() * 2, // Double for high DPI
          errorBuilder: (_, __, ___) => const Icon(Icons.person),
        ),
      ),
    );
  }
}

class _ChallengerList extends StatelessWidget {
  final List<Map<String, dynamic>> challengers;

  const _ChallengerList({required this.challengers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOP 50 CHALLENGERS', style: AppTextStyles.label(10, color: AppColors.onSurfaceVariant, weight: FontWeight.bold, letterSpacing: 4.0)),
              ],
            ),
          ),
          ...challengers.asMap().entries.map((entry) => _ChallengerItem(rank: entry.key + 4, profile: entry.value)),
        ],
      ),
    );
  }
}

class _ChallengerItem extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> profile;

  const _ChallengerItem({required this.rank, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        children: [
          Text('#$rank', style: AppTextStyles.headline(16, weight: FontWeight.w900)),
          const SizedBox(width: 24),
          _Avatar(url: profile['avatar_url'], color: Colors.white10, size: 40),
          const SizedBox(width: 16),
          Text(profile['username'], style: AppTextStyles.label(12, weight: FontWeight.bold)),
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
        Positioned(top: 100, left: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.08))).withBlur(120)),
      ],
    );
  }
}

extension _BlurExtension on Widget {
  Widget withBlur(double sigma) => ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma), child: this);
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
