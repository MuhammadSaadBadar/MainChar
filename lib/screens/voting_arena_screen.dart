import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/global_top_nav.dart';
import '../widgets/main_header.dart';
import '../widgets/activity_chip.dart';
import '../constants/university_activities.dart';

class VotingArenaScreen extends StatefulWidget {
  const VotingArenaScreen({super.key});

  @override
  State<VotingArenaScreen> createState() => _VotingArenaScreenState();
}

class _VotingArenaScreenState extends State<VotingArenaScreen> {
  final CardSwiperController _controller = CardSwiperController();
  List<Map<String, dynamic>> _profiles = [];
  Map<String, dynamic>? _currentUserProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_fetchCurrentUser(), _fetchProfiles()]);

    final args = Get.arguments;
    if (args != null &&
        args is Map<String, dynamic> &&
        args['initialProfile'] != null) {
      final initialProfile = args['initialProfile'] as Map<String, dynamic>;
      _profiles.removeWhere((p) => p['id'] == initialProfile['id']);
      _profiles.insert(0, initialProfile);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      _currentUserProfile = response;
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
  }

  Future<void> _fetchProfiles() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final List<dynamic> response = await Supabase.instance.client.rpc(
        'get_random_profiles',
        params: {'viewer_id': user.id, 'profile_limit': 10},
      );

      _profiles = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _handleSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final targetProfile = _profiles[previousIndex];
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return false;

    // Right/Action = Recognized (KNOW THIS GUY)
    final bool isRecognized = direction == CardSwiperDirection.right;

    try {
      await Supabase.instance.client.from('votes').insert({
        'voter_id': user.id,
        'target_id': targetProfile['id'],
        'is_recognized': isRecognized,
      });
      return true;
    } catch (e) {
      debugPrint('Error saving vote: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _MainCharacterGradient(),
          const _GrainOverlay(),
          Column(
            children: [
              MainHeader(
                title: 'ARENA',
                avatarUrl: _currentUserProfile?['avatar_url'],
                username: _currentUserProfile?['username'],
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _ArenaHeading(),
                          const SizedBox(height: 32),
                          _profiles.isEmpty
                              ? _buildEmptyState()
                              : _buildCardArena(),
                          const SizedBox(height: 64),
                          const _SwipeInstructions(),
                        ],
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CardSwiper(
            controller: _controller,
            cardsCount: _profiles.length,
            onSwipe: _handleSwipe,
            numberOfCardsDisplayed: _profiles.length == 1 ? 1 : 2,
            backCardOffset: const Offset(4, -10),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            cardBuilder:
                (context, index, horizontalThreshold, verticalThreshold) {
                  final profile = _profiles[index];
                  return _VotingCard(profile: profile);
                },
          ),
          Positioned(
            bottom: -48,
            left: 0,
            right: 0,
            child: _ActionControls(
              onSkip: () => _controller.swipe(CardSwiperDirection.left),
              onVote: () => _controller.swipe(CardSwiperDirection.right),
              onAction: () => _controller.swipe(CardSwiperDirection.right),
            ),
          ),
        ],
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
          'Check back later for new candidates.',
          style: AppTextStyles.body(14, color: AppColors.onSurfaceVariant),
        ),
      ],
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
          ),
          child: Text(
            'ACTIVE SESSION',
            style: AppTextStyles.label(
              10,
              color: AppColors.secondary,
              weight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: GlobalTopNav(),
          ),
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (avatarUrl != null)
            Image.network(
              avatarUrl,
              fit: BoxFit.cover,
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
                MediaQuery.of(context).size.width > 600 ? 40 : 32,
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
                    profile['bio'] ?? 'MAIN CHARACTER VIBE',
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

class _ActionControls extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onVote;
  final VoidCallback onAction;

  const _ActionControls({
    required this.onSkip,
    required this.onVote,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(icon: Icons.close, onTap: onSkip, size: 56),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: onAction,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                Text(
                  'KNOW THIS GUY',
                  style: AppTextStyles.headline(
                    14,
                    color: Colors.black,
                    weight: FontWeight.w900,
                    italic: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        _CircleButton(
          icon: Icons.favorite,
          onTap: onVote,
          size: 56,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool isPrimary;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.size,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariant,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _SwipeInstructions extends StatelessWidget {
  const _SwipeInstructions();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.keyboard_arrow_left, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'SWIPE LEFT TO SKIP',
            style: AppTextStyles.label(
              10,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'SWIPE RIGHT TO VOTE',
            style: AppTextStyles.label(
              10,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_right, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}
