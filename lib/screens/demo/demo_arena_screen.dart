import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_header.dart';
import '../../widgets/activity_chip.dart';
import '../../constants/university_activities.dart';
import 'demo_nav.dart';

class DemoArenaScreen extends StatefulWidget {
  const DemoArenaScreen({super.key});

  @override
  State<DemoArenaScreen> createState() => _DemoArenaScreenState();
}

class _DemoArenaScreenState extends State<DemoArenaScreen> {
  final CardSwiperController _controller = CardSwiperController();
  bool _isLoading = true;

  // Dummy candidates mirroring the VotingArenaScreen requirements
  final List<Map<String, dynamic>> _candidates = [
    {
      'id': '1',
      'username': 'DemoUser Alpha',
      'avatar_url': 'assets/image1.webp',
      'vibe_tags': ['Sports', 'Music'],
    },
    {
      'id': '2',
      'username': 'DemoUser Beta',
      'avatar_url': 'assets/image2.webp',
      'vibe_tags': ['Tech', 'Art'],
    },
    {
      'id': '3',
      'username': 'DemoUser Gamma',
      'avatar_url': 'assets/image3.webp',
      'vibe_tags': ['Gaming', 'Code'],
    },
    {
      'id': '4',
      'username': 'DemoUser Delta',
      'avatar_url': 'assets/image4.webp',
      'vibe_tags': ['Dance', 'Movies'],
    },
    {
      'id': '5',
      'username': 'DemoUser Epsilon',
      'avatar_url': 'assets/image5.webp',
      'vibe_tags': ['Books', 'Coffee'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (currentIndex == null || currentIndex >= _candidates.length - 1) {
      Get.snackbar(
        'Arena Empty',
        'Register to see more people!',
        backgroundColor: AppColors.secondary,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundImage(),
          const _MainCharacterGradient(),
          const _GrainOverlay(),
          Column(
            children: [
              const DemoHeader(title: 'ARENA'),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const _ArenaHeading(),
                            const SizedBox(height: 32),
                            _candidates.isEmpty
                                ? _buildEmptyState()
                                : _buildCardArena(),
                            const SizedBox(height: 24),
                            const _SwipeInstructions(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardArena() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      child: CardSwiper(
        controller: _controller,
        cardsCount: _candidates.length,
        onSwipe: _onSwipe,
        numberOfCardsDisplayed: _candidates.length == 1 ? 1 : 2,
        backCardOffset: const Offset(4, -10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
          final profile = _candidates[index];
          return _VotingCard(profile: profile);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Icon(
          Icons.sentiment_satisfied_rounded,
          size: 80,
          color: Colors.white24,
        ),
        const SizedBox(height: 24),
        Text(
          'ARENA CLEARED',
          style: AppTextStyles.headline(
            24,
            color: Colors.white24,
            italic: true,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register to find the real Main Characters.',
          style: AppTextStyles.body(14, color: AppColors.onSurfaceVariant),
        ),
      ],
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
            Image.asset(
              'assets/voting_background.webp',
              fit: BoxFit.cover,
              cacheWidth: 1080,
            ),
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

class _MainCharacterGradient extends StatelessWidget {
  const _MainCharacterGradient();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
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
          bottom: -100,
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

class _ArenaHeading extends StatelessWidget {
  const _ArenaHeading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: AppColors.secondary.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(100),
        //     border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        //   ),
        //   child: Text(
        //     'ACTIVE SESSION',
        //     style: AppTextStyles.label(
        //       10,
        //       color: AppColors.secondary,
        //       weight: FontWeight.bold,
        //       letterSpacing: 2,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: AppTextStyles.headline(48, weight: FontWeight.w900),
            children: [
              const TextSpan(text: 'VOTING '),
              TextSpan(
                text: 'ARENA',
                style: AppTextStyles.headline(
                  48,
                  color: AppColors.primary,
                  italic: true,
                  weight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        if (MediaQuery.of(context).size.width < 768)
          const Padding(padding: EdgeInsets.only(top: 24), child: DemoNav()),
      ],
    );
  }
}

class _VotingCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _VotingCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile['avatar_url'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (avatarUrl != null)
            Image.asset(
              avatarUrl,
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (c, e, s) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.2, 0.6, 1.0],
              ),
            ),
          ),
          // Top Left Identity
          Positioned(
            top: 32,
            left: 32,
            child: Text(
              (profile['username'] ?? 'User').toString().toUpperCase(),
              style: AppTextStyles.headline(
                MediaQuery.of(context).size.width > 600 ? 40 : 28,
                weight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          // Bottom Content (Activities Only)
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile['vibe_tags'] != null &&
                    (profile['vibe_tags'] as List).isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (profile['vibe_tags'] as List).map((tag) {
                      final activity = UniversityActivities.fromLabel(
                        tag.toString(),
                      );
                      return ActivityChip(
                        label: tag.toString(),
                        icon: activity?.icon ?? '✨',
                        isCompact: true,
                      );
                    }).toList(),
                  )
                else
                  Text(
                    'University Student',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Icon(Icons.person, size: 100, color: Colors.white10),
    );
  }
}

class _SwipeInstructions extends StatelessWidget {
  const _SwipeInstructions();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.keyboard_arrow_left,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'DK THIS PERSON?',
                style: AppTextStyles.label(
                  11,
                  color: Colors.white70,
                  weight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                ' SWIPE LEFT',
                style: AppTextStyles.label(
                  11,
                  color: AppColors.primary,
                  weight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 24),
              Container(width: 1, height: 12, color: Colors.white10),
              const SizedBox(width: 24),
              Text(
                'KNOW THIS GUY?',
                style: AppTextStyles.label(
                  11,
                  color: Colors.white70,
                  weight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                ' SWIPE RIGHT',
                style: AppTextStyles.label(
                  11,
                  color: AppColors.secondary,
                  weight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.keyboard_arrow_right,
                size: 18,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
