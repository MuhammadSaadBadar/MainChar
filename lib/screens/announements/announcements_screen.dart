import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mainchar/routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_header.dart';
import '../../controllers/announcement_controller.dart';
import '../../models/announcement.dart';
import '../../widgets/global_top_nav.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final AnnouncementController _controller = Get.put(AnnouncementController());
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.markAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'myRequestsBtn',
            onPressed: () => Get.toNamed(AppRoutes.MY_REQUESTS),
            backgroundColor: AppColors.surfaceContainerHigh,
            foregroundColor: AppColors.onSurface,
            icon: const Icon(Icons.list_alt, size: 20),
            label: Text(
              "MY REQUESTS",
              style: AppTextStyles.label(
                12,
                weight: FontWeight.w900,
                color: AppColors.onSurface,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'newRequestBtn',
            onPressed: () => Get.toNamed(AppRoutes.REQUEST_EVENT),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              "NEW REQUEST",
              style: AppTextStyles.label(
                12,
                weight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const _GrainOverlay(),
          Column(
            children: [
              const MainHeader(title: "CAMPUS MUSE"),
              if (MediaQuery.of(context).size.width < 768)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: const GlobalTopNav(),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 900;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Panel - Timeline
                          SizedBox(
                            width: isDesktop ? 320.0 : constraints.maxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "THE WIRE",
                                      style: AppTextStyles.headline(
                                        36,
                                        weight: FontWeight.w900,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6.0,
                                      ),
                                      child: Text(
                                        "LIVE UPDATES",
                                        style: AppTextStyles.label(
                                          12,
                                          color: AppColors.secondary,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Obx(() {
                                    if (_controller
                                        .approvedAnnouncements
                                        .isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .surfaceContainerHigh
                                                      .withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.primary
                                                        .withOpacity(0.1),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.blur_on_rounded,
                                                  size: 48,
                                                  color: AppColors.primary
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              Text(
                                                "THE WIRE IS QUIET",
                                                style: AppTextStyles.headline(
                                                  18,
                                                  weight: FontWeight.w900,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                "No live broadcasts at the moment.\nBe the one to break the silence.",
                                                textAlign: TextAlign.center,
                                                style: AppTextStyles.body(
                                                  12,
                                                  color: AppColors
                                                      .onSurfaceVariant
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              const SizedBox(height: 32),
                                              TextButton.icon(
                                                onPressed: () => Get.toNamed(
                                                  AppRoutes.REQUEST_EVENT,
                                                ),
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  "CREATE ANNOUNCEMENT",
                                                  style: AppTextStyles.label(
                                                    10,
                                                    weight: FontWeight.w900,
                                                    letterSpacing: 1.5,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12,
                                                      ),
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withOpacity(0.1),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return ListView.separated(
                                      itemCount: _controller
                                          .approvedAnnouncements
                                          .length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        final item = _controller
                                            .approvedAnnouncements[index];
                                        final isSelected =
                                            isDesktop &&
                                            _selectedIndex == index;
                                        return _AnnouncementTile(
                                          announcement: item,
                                          isSelected: isSelected,
                                          onTap: () {
                                            setState(
                                              () => _selectedIndex = index,
                                            );
                                            if (!isDesktop) {
                                              Get.bottomSheet(
                                                _MobileDetailSheet(
                                                  announcement: item,
                                                ),
                                                isScrollControlled: true,
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 24),
                            // Right Panel - Detail View
                            Expanded(
                              child: Obx(() {
                                if (_controller.approvedAnnouncements.isEmpty) {
                                  return const SizedBox();
                                }
                                if (_selectedIndex >=
                                    _controller.approvedAnnouncements.length) {
                                  _selectedIndex = 0;
                                }
                                return _DetailView(
                                  announcement: _controller
                                      .approvedAnnouncements[_selectedIndex],
                                );
                              }),
                            ),
                          ],
                        ],
                      );
                    },
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

class _AnnouncementTile extends StatelessWidget {
  final Announcement announcement;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnnouncementTile({
    required this.announcement,
    required this.isSelected,
    required this.onTap,
  });

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return "${diff.inMinutes} MINS AGO";
    if (diff.inHours < 24) return "${diff.inHours} HOURS AGO";
    return "${diff.inDays} DAYS AGO";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceContainerHigh
              : AppColors.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.secondary.withOpacity(0.5),
                  width: 2,
                )
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      announcement.category.toUpperCase(),
                      style: AppTextStyles.label(
                        10,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    style: AppTextStyles.headline(18, weight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTimeAgo(announcement.createdAt),
                        style: AppTextStyles.label(
                          10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (DateTime.now()
                              .difference(announcement.createdAt)
                              .inHours <
                          24)
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: AppColors.secondary,
                              size: 14,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final Announcement announcement;

  const _DetailView({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [AppColors.primary.withOpacity(0.05), Colors.transparent],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Vertical Accent Line
          Positioned(
            left: 0,
            top: 40,
            bottom: 40,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.5),
                    AppColors.secondary.withOpacity(0.5),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          announcement.category.toUpperCase(),
                          style: AppTextStyles.label(
                            10,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        announcement.title,
                        style: AppTextStyles.headline(
                          36,
                          weight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.description,
                        style: AppTextStyles.body(
                          18,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (announcement.location.isNotEmpty ||
                          announcement.eventTime.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            if (announcement.location.isNotEmpty)
                              Expanded(
                                child: _InfoBox(
                                  icon: Icons.location_on,
                                  iconColor: AppColors.primary,
                                  label: "LOCATION",
                                  value: announcement.location,
                                ),
                              ),
                            if (announcement.location.isNotEmpty &&
                                announcement.eventTime.isNotEmpty)
                              const SizedBox(width: 16),
                            if (announcement.eventTime.isNotEmpty)
                              Expanded(
                                child: _InfoBox(
                                  icon: Icons.schedule,
                                  iconColor: AppColors.secondary,
                                  label: "TIME",
                                  value: announcement.eventTime,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (announcement.rules.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _RulesBlock(rules: announcement.rules),
                      ],
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
}

class _MobileDetailSheet extends StatelessWidget {
  final Announcement announcement;

  const _MobileDetailSheet({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            announcement.category.toUpperCase(),
                            style: AppTextStyles.label(
                              9,
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Get.back(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      announcement.title,
                      style: AppTextStyles.headline(
                        28,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.description,
                      style: AppTextStyles.body(
                        16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (announcement.location.isNotEmpty) ...[
                      _InfoBox(
                        icon: Icons.location_on,
                        iconColor: AppColors.primary,
                        label: "LOCATION",
                        value: announcement.location,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (announcement.eventTime.isNotEmpty) ...[
                      _InfoBox(
                        icon: Icons.schedule,
                        iconColor: AppColors.secondary,
                        label: "TIME",
                        value: announcement.eventTime,
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (announcement.rules.isNotEmpty) ...[
                      _RulesBlock(rules: announcement.rules),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesBlock extends StatelessWidget {
  final String rules;

  const _RulesBlock({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gavel_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                "RULES & GUIDELINES",
                style: AppTextStyles.label(
                  12,
                  color: AppColors.primary,
                  weight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            rules,
            style: AppTextStyles.body(16, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
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
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.headline(16, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
