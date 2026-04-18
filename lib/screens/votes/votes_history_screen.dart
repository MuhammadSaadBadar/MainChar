import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/global_top_nav.dart';
import '../../widgets/main_header.dart';
import '../../routes/app_routes.dart';

class VotesHistoryScreen extends StatefulWidget {
  const VotesHistoryScreen({super.key});

  @override
  State<VotesHistoryScreen> createState() => _VotesHistoryScreenState();
}

class _VotesHistoryScreenState extends State<VotesHistoryScreen> {
  bool _isLoading = true;
  bool _isRevealWindow = false;
  bool _testBypass = false;
  late Timer _timer;
  Duration _timeLeft = const Duration(days: 0);
  List<Map<String, dynamic>> _voters = [];

  @override
  void initState() {
    super.initState();
    _checkRevealStatus();
    _startTimer();
    if (_isRevealWindow || _testBypass) {
      _fetchVoters();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _checkRevealStatus() {
    final now = DateTime.now();
    // The window is 1st of every month at 12:00 PM to 12:20 PM
    final currentMonthFirst = DateTime(now.year, now.month, 1, 12, 0);
    final currentMonthFirstEnd = DateTime(now.year, now.month, 1, 12, 20);

    bool inWindow =
        now.isAfter(currentMonthFirst) && now.isBefore(currentMonthFirstEnd);

    // For manual test bypass
    if (_testBypass) {
      inWindow = true;
    }

    setState(() {
      _isRevealWindow = inWindow;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      final currentMonthFirst = DateTime(now.year, now.month, 1, 12, 0);
      final currentMonthFirstEnd = DateTime(now.year, now.month, 1, 12, 20);

      DateTime targetDate;
      if (now.isBefore(currentMonthFirst)) {
        targetDate = currentMonthFirst;
      } else if (now.isBefore(currentMonthFirstEnd)) {
        // We are currently in the window!
        targetDate =
            currentMonthFirstEnd; // or keep it showing "0" or "Unlocked"
      } else {
        // We missed this month's window, look at next month's 1st
        targetDate = DateTime(now.year, now.month + 1, 1, 12, 0);
      }

      final inWindow =
          now.isAfter(currentMonthFirst) &&
              now.isBefore(currentMonthFirstEnd) ||
          _testBypass;

      if (mounted) {
        setState(() {
          _timeLeft = targetDate.difference(now);
          if (_isRevealWindow != inWindow) {
            _isRevealWindow = inWindow;
            if (_isRevealWindow) {
              _fetchVoters();
            } else {
              _voters.clear();
            }
          }
        });
      }
    });
  }

  Future<void> _fetchVoters() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('votes')
          .select(
            'voter_id, created_at, is_recognized, voter:users!votes_voter_id_fkey(id, username, avatar_url, bio)',
          )
          .eq('target_id', user.id)
          .eq('is_recognized', true)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _voters = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching voters: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleBypass() {
    setState(() {
      _testBypass = !_testBypass;
      _checkRevealStatus();
      if (_isRevealWindow) {
        _fetchVoters();
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

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
              SliverToBoxAdapter(child: const MainHeader(title: 'CAMPUS VIBE')),
              if (MediaQuery.of(context).size.width < 768)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: GlobalTopNav()),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              // Temporary Bypass Button (Double Tap to trigger)
                              GestureDetector(
                                onDoubleTap: _toggleBypass,
                                child: Text(
                                  'MY SUPPORTERS',
                                  style: AppTextStyles.label(
                                    14,
                                    color: AppColors.primary,
                                    weight: FontWeight.bold,
                                    letterSpacing: 3.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // Balance for arrow
                            ],
                          ),
                          const SizedBox(height: 64),
                          if (_isLoading)
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            )
                          else if (!_isRevealWindow)
                            _CountdownSection(timeLeft: _timeLeft)
                          else
                            _VotersList(voters: _voters),
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
  final Duration timeLeft;
  const _CountdownSection({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.onSurfaceVariant.withOpacity(0.2),
            ),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 64,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 48),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Reveals in\n',
                style: AppTextStyles.headline(
                  32,
                  weight: FontWeight.w900,
                  color: Colors.white70,
                ),
              ),
              TextSpan(
                text: '${timeLeft.inDays} Days\n',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 768 ? 84 : 64,
                  weight: FontWeight.w900,
                  color: AppColors.primary,
                  italic: true,
                ),
              ),
              TextSpan(
                text:
                    '${timeLeft.inHours.remainder(24)}h ${timeLeft.inMinutes.remainder(60)}m',
                style: AppTextStyles.headline(
                  32,
                  weight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 800.ms),
        const SizedBox(height: 32),
        Text(
          'VOTES ARE ONLY REVEALED ON THE 1ST OF EVERY MONTH AT 12:00 PM FOR 20 MINUTES.',
          textAlign: TextAlign.center,
          style: AppTextStyles.label(
            12,
            color: AppColors.onSurfaceVariant,
            weight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class _VotersList extends StatelessWidget {
  final List<Map<String, dynamic>> voters;

  const _VotersList({required this.voters});

  @override
  Widget build(BuildContext context) {
    if (voters.isEmpty) {
      return Center(
        child: Text(
          'No recognitions yet. Stay active to get noticed!',
          style: AppTextStyles.body(16, color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE REVEAL WINDOW',
                style: AppTextStyles.label(
                  10,
                  color: AppColors.primary,
                  weight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: voters.length,
          itemBuilder: (context, index) {
            final voterData =
                voters[index]['voter'] as Map<String, dynamic>? ?? {};
            return _VoterItem(profile: voterData, index: index);
          },
        ),
      ],
    );
  }
}

class _VoterItem extends StatelessWidget {
  final Map<String, dynamic> profile;
  final int index;

  const _VoterItem({required this.profile, required this.index});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile['avatar_url'] as String?;
    final username = profile['username'] as String? ?? 'Unknown';
    final bio = profile['bio'] as String? ?? 'Student';
    final targetUserId = profile['id'] as String?;

    return GestureDetector(
      onTap: () {
        if (targetUserId != null) {
          Get.toNamed(AppRoutes.PROFILE, arguments: {'userId': targetUserId});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.person, color: Colors.white54),
                      )
                    : const Icon(Icons.person, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.toUpperCase(),
                    style: AppTextStyles.label(16, weight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bio,
                    style: AppTextStyles.label(
                      10,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
                  Icons.electric_bolt_rounded,
                  color: AppColors.secondary,
                  size: 24,
                )
                .animate(delay: (index * 100).ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
    );
  }
}

// Reusing background elements from Leaderboard
class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ).withBlur(120),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.06),
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
