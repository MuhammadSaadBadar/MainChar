import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Logic state
  File? _imageFile;
  String? _existingAvatarUrl;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  // New state from design
  final List<String> _selectedTags = ['Trendsetter'];
  final List<String> _availableTags = [
    'Nocturnal',
    'Academic Weapon',
    'Trendsetter',
    'Digital Nomad',
    'Hypebeast',
    'Artist',
    'Developer',
  ];

  // UI State
  bool _ghostMode = true;
  bool _auraVisibility = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingProfile();
    // Update live preview when typing
    _usernameController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
  }

  Future<void> _fetchExistingProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _usernameController.text = response['username'] ?? '';
          _bioController.text = response['bio'] ?? '';
          _existingAvatarUrl = response['avatar_url'];
          if (response['vibe_tags'] != null) {
            _selectedTags.clear();
            _selectedTags.addAll(List<String>.from(response['vibe_tags']));
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _saveProfile() async {
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();
    final user = Supabase.instance.client.auth.currentUser;

    if (username.isEmpty || user == null) {
      Get.snackbar(
        'Error',
        'Username is required',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? avatarUrl = _existingAvatarUrl;

      // 1. Upload new image if picked
      if (_imageFile != null) {
        final String filePath =
            '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(filePath, _imageFile!);
        avatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(filePath);
      }

      // 2. Upsert profile
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'username': username,
        'bio': bio,
        'avatar_url': avatarUrl,
        'vibe_tags': _selectedTags,
        'campus_email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        'Aura Saved',
        'Your identity has been updated.',
        backgroundColor: AppColors.secondary,
        colorText: Colors.black,
      );

      // Navigate back or to home
      Get.offAllNamed(AppRoutes.NAV);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          const _GrainOverlay(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const _TopNav(),
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
                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 7, child: _buildForm()),
                                  const SizedBox(width: 64),
                                  Expanded(flex: 5, child: _buildPreview()),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildForm(),
                                  const SizedBox(height: 64),
                                  _buildPreview(),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _Footer()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormHeader(),
        const SizedBox(height: 48),
        // Avatar Upload
        _SectionLabel(label: 'VIBE CAPTURE'),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.surfaceContainerHighest,
                        width: 4,
                      ),
                      image: _getImageProvider() != null
                          ? DecorationImage(
                              image: _getImageProvider()!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _getImageProvider() == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.white24,
                          )
                        : null,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white.withOpacity(0.0),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'UPLOAD NEW AURA',
                    style: AppTextStyles.label(
                      10,
                      weight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PNG, JPG UP TO 10MB',
                  style: AppTextStyles.body(
                    10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Username
        _SectionLabel(label: 'IDENTITY TOKEN'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _usernameController,
            style: AppTextStyles.body(18, weight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Enter your alias...',
              hintStyle: AppTextStyles.body(18, color: AppColors.outline),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 24),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Bio
        _SectionLabel(label: 'THE MANIFESTO'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _bioController,
            maxLines: 4,
            style: AppTextStyles.body(16, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: "What's your campus legend?",
              hintStyle: AppTextStyles.body(16, color: AppColors.outline),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Vibe Tags
        _SectionLabel(label: 'SELECT YOUR VIBE'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableTags
              .map(
                (tag) => _VibeChip(
                  label: tag,
                  isSelected: _selectedTags.contains(tag),
                  onTap: () {
                    setState(() {
                      if (_selectedTags.contains(tag)) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 48),
        // Privacy Toggles
        _SectionLabel(label: 'PRIVACY ENCRYPT'),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          child: Column(
            children: [
              _PrivacyToggle(
                label: 'Ghost Mode',
                subLabel: 'Hide your location from non-mutuals',
                value: _ghostMode,
                onChanged: (v) => setState(() => _ghostMode = v),
              ),
              _PrivacyToggle(
                label: 'Aura Visibility',
                subLabel: 'Only verified EDU accounts can see profile',
                value: _auraVisibility,
                onChanged: (v) => setState(() => _auraVisibility = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        // Final Action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 20,
              shadowColor: AppColors.secondary.withOpacity(0.3),
            ),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(
                    'SAVE YOUR AURA',
                    style: AppTextStyles.headline(
                      24,
                      color: Colors.black,
                      weight: FontWeight.w900,
                      italic: true,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 32, height: 1, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'LIVE PREVIEW',
              style: AppTextStyles.label(
                10,
                color: AppColors.primary,
                weight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _PreviewCard(
          username: _usernameController.text,
          bio: _bioController.text,
          imageProvider: _getImageProvider(),
          tags: _selectedTags,
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_existingAvatarUrl != null) {
      return NetworkImage(_existingAvatarUrl!);
    }
    return null;
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
          bottom: 150,
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

class _TopNav extends StatelessWidget {
  const _TopNav();

  @override
  Widget build(BuildContext context) {
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
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDgNy4SOaz2q9LLIfeapbFuz_vcSHBhTHGL8dpR-0qdTc_X5kAJAo6MRDUkghXcMzJsn3CWAiZ2oxdLQiEaMMG6KPc0QzWdy23l7-c7F29jBaMPbUPa-ZFC1i84h-TW4ccQyn5Nsdrh0E5OQkHXzq1HrK85dZiNxbEY50OqhNVXIi4Fy0on2gTwJ99-6cwT4paKAFPb9qAWuoHxEKQFn8kX1NpkL47dONiND_70uH9tuxVcPuqGDYCUe5cmPtlfYaOaqQg1bVH60ek',
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

class _FormHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'EDIT ',
                style: AppTextStyles.headline(72, weight: FontWeight.w900),
              ),
              TextSpan(
                text: 'IDENTITY',
                style: AppTextStyles.headline(
                  72,
                  weight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Refine your digital presence. Elevate your aura on campus.',
          style: AppTextStyles.body(18, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.headline(
        20,
        color: AppColors.primary,
        weight: FontWeight.w900,
      ),
    );
  }
}

class _VibeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _VibeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceContainerHigh,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.label(
            10,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            letterSpacing: 2.0,
            weight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool value;
  final Function(bool) onChanged;

  const _PrivacyToggle({
    required this.label,
    required this.subLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.headline(14, weight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subLabel,
                  style: AppTextStyles.body(
                    12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => onChanged(!value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.secondary
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(4),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: value ? Colors.black : AppColors.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String username;
  final String bio;
  final ImageProvider? imageProvider;
  final List<String> tags;

  const _PreviewCard({
    required this.username,
    required this.bio,
    this.imageProvider,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: const Color(0xFF262626).withOpacity(0.6),
            child: Column(
              children: [
                // Banner
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.4,
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBH5GGyckW0KTuAWA87tDX8bZlTIQvnvXspWOzUjT3c1XP7UK5Qz9gLYAoCA4FHQndiKjmWuKFX-Wx-B9wHNr7lA9pZh0nTeHtJK5-XTby0Md6vm9wBV7EZ-ieLH0KlRyFQQ7YOdJ8XLDJRlSv8v-D7LAiO4qaYMXp8Lz6K-mJaYOinZNC1iciuzATLDDOlYdr_61r46JxigWXgHqRjjJX9IpUFLP6Q21-NB1SXcwTMB8ZzfuGbJ_tbt45eRHjgP5zRc9RwgxETne0',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -64),
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 6,
                            ),
                            image: imageProvider != null
                                ? DecorationImage(
                                    image: imageProvider!,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: AppColors.surfaceContainer,
                          ),
                          child: imageProvider == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: Colors.white24,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: -48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username.isNotEmpty
                                    ? username.toUpperCase()
                                    : 'IDENTITY TOKEN',
                                style: AppTextStyles.headline(
                                  32,
                                  weight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '@${username.toLowerCase().replaceAll(' ', '_')}',
                                style: AppTextStyles.label(
                                  10,
                                  color: AppColors.secondary,
                                  weight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'LEVEL 42',
                              style: AppTextStyles.label(
                                8,
                                color: AppColors.primary,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bio.isNotEmpty
                            ? bio
                            : "Your campus legend will appear here...",
                        style: AppTextStyles.body(
                          14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        children: tags
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  t.toUpperCase(),
                                  style: AppTextStyles.label(
                                    8,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(label: 'Aura', value: '1.2k'),
                          _StatItem(label: 'Followers', value: '842'),
                          _StatItem(label: 'Vibes', value: '12'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headline(24, weight: FontWeight.w900)),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label(
            8,
            color: AppColors.onSurfaceVariant,
            weight: FontWeight.bold,
            letterSpacing: 2.0,
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
        border: Border(top: BorderSide(color: Color(0xFF20201F))),
      ),
      child: Column(
        children: [
          Text(
            'CAMPUS VIBE',
            style: AppTextStyles.headline(
              24,
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
