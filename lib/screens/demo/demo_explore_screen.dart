import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/demo_header.dart';
import '../../widgets/activity_chip.dart';
import '../../constants/university_activities.dart';
import 'demo_nav.dart';

class DemoExploreScreen extends StatefulWidget {
  const DemoExploreScreen({super.key});

  @override
  State<DemoExploreScreen> createState() => _DemoExploreScreenState();
}

class _DemoExploreScreenState extends State<DemoExploreScreen> {
  final List<Map<String, dynamic>> _dummyItems = List.generate(20, (index) {
    final imgIndex = (index % 5) + 1;
    final ratios = ['0.8', '1.0', '1.1', '1.25', '1.33'];
    final vibes = [
      ['Sports', 'Music'],
      ['Tech', 'Art'],
      ['Gaming', 'Code'],
      ['Dance', 'Movies'],
      ['Books', 'Coffee'],
    ];
    return {
      'id': index.toString(),
      'name': 'DemoUser ${index + 1}',
      'image': 'assets/image$imgIndex.webp',
      'ratio': ratios[index % ratios.length],
      'vibe_tags': vibes[index % vibes.length],
    };
  });

  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_dummyItems);
    _simulateLoading();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        if (query.isEmpty) {
          _filteredItems = List.from(_dummyItems);
        } else {
          _filteredItems = _dummyItems
              .where((item) => (item['name'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
        }
      });
    });
  }

  void _shuffleVibes() {
    _simulateLoading().then((_) {
      if (mounted) {
        setState(() {
          _filteredItems.shuffle();
        });
      }
    });
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
          Column(
            children: [
              const DemoHeader(title: 'CAMPUS VIBE'),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (MediaQuery.of(context).size.width < 768)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 32),
                                    child: Center(child: DemoNav()),
                                  ),
                                _SearchHeader(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                ),
                                const SizedBox(height: 64),
                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : _filteredItems.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No vibes found matching "$_searchQuery"',
                                              style: AppTextStyles.body(
                                                16,
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          )
                                        : _MasonryFeed(profiles: _filteredItems),
                                const SizedBox(height: 64),
                                Center(
                                  child: _RefreshButton(
                                    isLoading: _isLoading,
                                    onRefresh: _shuffleVibes,
                                  ),
                                ),
                                const _Footer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            Image.asset(
              'assets/explore_background.webp',
              fit: BoxFit.cover,
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

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _SearchHeader({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: AppTextStyles.body(
                    MediaQuery.of(context).size.width > 360 ? 18 : 16,
                    weight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search the campus elite...',
                    hintStyle: AppTextStyles.body(
                      MediaQuery.of(context).size.width > 360 ? 18 : 16,
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MasonryFeed extends StatelessWidget {
  final List<Map<String, dynamic>> profiles;
  const _MasonryFeed({required this.profiles});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.extent(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      maxCrossAxisExtent: 380,
      mainAxisSpacing: 32,
      crossAxisSpacing: 32,
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        return _ProfileCard(profile: profiles[index]);
      },
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;

  const _RefreshButton({required this.isLoading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onRefresh,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.refresh_rounded, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              isLoading ? 'LOADING...' : 'SHUFFLE VIBES',
              style: AppTextStyles.headline(
                14,
                color: Colors.black,
                weight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final ratio = double.parse(profile['ratio']!);

    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Join the Grid',
          'Register to view full profiles!',
          backgroundColor: AppColors.secondary,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: ratio,
                child: Image.asset(
                  profile['image'],
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white10,
                      ),
                    );
                  },
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final cardHeight = boxConstraints.maxHeight;
                    final isVeryShort = cardHeight < 150;
                    final isSmall = cardHeight < 200;

                    return Padding(
                      padding: EdgeInsets.all(isSmall ? 12.0 : 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.headline(
                                    isVeryShort ? 18 : 24,
                                    color: Colors.white,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                                if (!isVeryShort) ...[
                                  const SizedBox(height: 8),
                                  if (profile['vibe_tags'] != null &&
                                      (profile['vibe_tags'] as List).isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: (profile['vibe_tags'] as List)
                                          .take(2)
                                          .map((tag) {
                                        final activity =
                                            UniversityActivities.fromLabel(
                                          tag.toString(),
                                        );
                                        return ActivityChip(
                                          label: tag.toString(),
                                          icon: activity?.icon ?? '✨',
                                          isCompact: true,
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          if (!isVeryShort) ...[
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.DEMO_ARENA,
                                  arguments: {
                                    'initialProfile': {
                                      'id': profile['id'],
                                      'username': profile['name'],
                                      'avatar_url': profile['image'],
                                      'vibe_tags': profile['vibe_tags'],
                                    },
                                  },
                                );
                              },
                              child: Container(
                                width: isSmall ? 40 : 48,
                                height: isSmall ? 40 : 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.electric_bolt_rounded,
                                  color: Colors.black,
                                  size: isSmall ? 20 : 24,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 16,
            children: const [
              _FooterLink(label: 'Support'),
              _FooterLink(label: 'Privacy'),
              _FooterLink(label: 'Terms'),
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
