import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_header.dart';
import '../../routes/app_routes.dart';
import 'demo_nav.dart';

class DemoVotesHistoryScreen extends StatefulWidget {
  const DemoVotesHistoryScreen({super.key});

  @override
  State<DemoVotesHistoryScreen> createState() => _DemoVotesHistoryScreenState();
}

class _DemoVotesHistoryScreenState extends State<DemoVotesHistoryScreen> {
  bool _isLoading = true;
  bool _isRevealWindow = false;
  bool _testBypass = false;
  late Timer _timer;
  Duration _timeLeft = const Duration(days: 7, hours: 2, minutes: 45);

  // Simulated voters based on the 5 demo users
  final List<Map<String, dynamic>> _voters = [
    {
      'voter': {
        'username': 'DemoUser Alpha',
        'avatar_url': 'assets/image1.webp',
        'bio': 'Campus Legend • Sports Lead',
      },
    },
    {
      'voter': {
        'username': 'DemoUser Beta',
        'avatar_url': 'assets/image2.webp',
        'bio': 'Tech Enthusiast • Hackathon Winner',
      },
    },
    {
      'voter': {
        'username': 'DemoUser Gamma',
        'avatar_url': 'assets/image3.webp',
        'bio': 'Music Producer • Vibe Master',
      },
    },
    {
      'voter': {
        'username': 'DemoUser Delta',
        'avatar_url': 'assets/image4.webp',
        'bio': 'Creative Designer • Pixel Perfect',
      },
    },
    {
      'voter': {
        'username': 'DemoUser Epsilon',
        'avatar_url': 'assets/image5.webp',
        'bio': 'Fitness Freak • Marathon Runner',
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Simulate initial loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleBypass() {
    setState(() {
      _testBypass = !_testBypass;
      _isRevealWindow = _testBypass;
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
              SliverToBoxAdapter(child: const DemoHeader(title: 'CAMPUS VIBE')),
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
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 64),

                          // Demo Mode Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              border: Border.all(
                                color: AppColors.onSurfaceVariant.withOpacity(
                                  0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'DEMO MODE',
                              style: AppTextStyles.label(
                                10,
                                color: AppColors.secondary,
                                weight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

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
                  MediaQuery.of(context).size.width > 360 ? 32 : 24,
                  weight: FontWeight.w900,
                  color: Colors.white70,
                ),
              ),
              TextSpan(
                text: '${timeLeft.inDays} Days\n',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 768
                      ? 84
                      : (MediaQuery.of(context).size.width > 400 ? 64 : 48),
                  weight: FontWeight.w900,
                  color: AppColors.primary,
                  italic: true,
                ),
              ),
              TextSpan(
                text:
                    '${timeLeft.inHours.remainder(24)}h ${timeLeft.inMinutes.remainder(60)}m',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 360 ? 32 : 24,
                  weight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 800.ms),
        const SizedBox(height: 32),
        Text(
          'GUEST NOTICE: DOUBLE TAP "MY SUPPORTERS" ABOVE TO UNLOCK DEMO VIEW.',
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
            final voterData = voters[index]['voter'] as Map<String, dynamic>;
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
    final avatarUrl = profile['avatar_url'] as String;
    final username = profile['username'] as String;
    final bio = profile['bio'] as String;

    return Container(
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
              child: Image.asset(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.person, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.toUpperCase(),
                  style: AppTextStyles.label(
                    MediaQuery.of(context).size.width > 360 ? 16 : 14,
                    weight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: AppTextStyles.label(
                    MediaQuery.of(context).size.width > 360 ? 10 : 9,
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
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }
}

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
