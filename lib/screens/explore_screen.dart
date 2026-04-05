import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/main_header.dart';
import '../widgets/activity_chip.dart';
import '../constants/university_activities.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  String? _avatarUrl;
  String? _username;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
        });
        _fetchProfiles();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('users')
          .select('avatar_url, username')
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() {
          _avatarUrl = data['avatar_url'] as String?;
          _username = data['username'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
  }

  Future<void> _fetchProfiles() async {
    setState(() => _isLoading = true);
    try {
      List<dynamic> response;
      if (_searchQuery.trim().isEmpty) {
        response = await Supabase.instance.client.rpc(
          'get_explore_profiles',
          params: {'profile_limit': 20},
        );
      } else {
        response = await Supabase.instance.client
            .from('users')
            .select()
            .ilike('username', '%${_searchQuery.trim()}%')
            .limit(20);
      }

      final random = Random();
      final ratios = ['0.8', '1.0', '1.1', '1.25', '1.33'];

      _profiles = response.map((data) {
        return {
          'id': data['id'],
          'name': data['username'] ?? 'User',
          'vibe_tags': List<String>.from(data['vibe_tags'] ?? []),
          'image': data['avatar_url'] as String?,
          'ratio': ratios[random.nextInt(ratios.length)],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching explore profiles: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          const _GrainOverlay(),
          Column(
            children: [
              MainHeader(
                title: 'EXPLORE',
                avatarUrl: _avatarUrl,
                username: _username,
              ),
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
                                    : _profiles.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No vibes found.',
                                          style: AppTextStyles.body(
                                            16,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      )
                                    : _MasonryFeed(profiles: _profiles),
                                const SizedBox(height: 64),
                                Center(
                                  child: _RefreshButton(
                                    isLoading: _isLoading,
                                    onRefresh: _fetchProfiles,
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

// Obsolete _NavLink removed

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: AppTextStyles.body(18, weight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search the campus elite...',
                    hintStyle: AppTextStyles.body(18, color: AppColors.outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
        //user dont want to implement this
        // const SizedBox(height: 32),
        // Row(
        //   children: [
        //     Text(
        //       'TRENDING NOW:',
        //       style: AppTextStyles.label(
        //         10,
        //         color: AppColors.onSurfaceVariant,
        //         letterSpacing: 2.0,
        //         weight: FontWeight.bold,
        //       ),
        //     ),
        //     const SizedBox(width: 16),
        //     const Wrap(
        //       spacing: 8,
        //       children: [
        //         _TrendingChip(label: '#DesignMajor'),
        //         _TrendingChip(label: '#VarsityVibe'),
        //         _TrendingChip(label: '#MidnightStudio'),
        //       ],
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

// class _TrendingChip extends StatelessWidget {
//   final String label;
//   const _TrendingChip({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.05),
//         border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//         borderRadius: BorderRadius.circular(100),
//       ),
//       child: Text(
//         label,
//         style: AppTextStyles.label(
//           12,
//           color: AppColors.primary,
//           weight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

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
              isLoading ? 'LOADING...' : 'REFRESH VIBES',
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
            Get.toNamed(
              AppRoutes.ARENA,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: ratio,
                    child: profile['image'] != null
                        ? Image.network(
                            profile['image']!,
                            fit: BoxFit.cover,
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
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.white10,
                            ),
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
                    top: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  profile['name']!,
                                  style: AppTextStyles.headline(
                                    28,
                                    color: Colors.white,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const SizedBox(height: 4),
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
                                      })
                                      .toList(),
                                )
                              else
                                Text(
                                  '',
                                  style: AppTextStyles.label(
                                    10,
                                    color: AppColors.primary,
                                    letterSpacing: 1.0,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.electric_bolt_rounded,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      ],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIcon(
                    icon: Icons.electric_bolt_rounded,
                    label: 'QUICK VOTE',
                    onTap: () {
                      if (Get.currentRoute != AppRoutes.ARENA) {
                        Get.offNamed(AppRoutes.ARENA);
                      }
                    },
                  ),
                  _NavIcon(
                    icon: Icons.search_rounded,
                    label: 'EXPLORE',
                    active: true,
                    onTap: () {},
                  ),
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
  final bool active;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: active
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
            : null,
        decoration: active
            ? BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(100),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.black : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label(
                8,
                color: active ? Colors.black : AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
