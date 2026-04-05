import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/global_top_nav.dart';
import '../widgets/main_header.dart';
import '../widgets/activity_chip.dart';
import '../widgets/activity_picker_sheet.dart';
import '../constants/university_activities.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRevealHour = false;
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  List<String> _selectedTags = [];
  Uint8List? _imageBytes;

  // Real-time Stats
  int _upvotesCount = 0;
  int _aura = 0;
  StreamSubscription? _votesSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkRevealStatus();
    _initRealtimeVotes();
  }

  @override
  void dispose() {
    _votesSubscription?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  void _checkRevealStatus() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _isRevealHour = (now.day == lastDay.day && now.hour == 20);
    });
  }

  void _initRealtimeVotes() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Listen for real-time updates to votes where this user is the target
    _votesSubscription = Supabase.instance.client
        .from('votes')
        .stream(primaryKey: ['id'])
        .eq('target_id', user.id)
        .listen((List<Map<String, dynamic>> data) {
          // Count only recognized votes
          final count = data.where((v) => v['is_recognized'] == true).length;

          if (mounted) {
            setState(() {
              _upvotesCount = count;
              // Simple Aura calculation (e.g., 50 aura per recognition)
              _aura = count * 50;
            });
          }
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
        _selectedTags = List<String>.from(response['vibe_tags'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _usernameController.text = _userData?['username'] ?? '';
        _selectedTags = List<String>.from(_userData?['vibe_tags'] ?? []);
        _imageBytes = null;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      debugPrint('Selected image: ${image.name}, size: ${bytes.length} bytes');
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _saveChanges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      String? avatarUrl = _userData?['avatar_url'];

      if (_imageBytes != null) {
        final filePath =
            '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

        debugPrint('Uploading to Supabase (Web Binary): $filePath');

        // Use uploadBinary to bypass the internal File check causing readAsBytesSync error on Web
        await (Supabase.instance.client.storage.from('avatars') as dynamic)
            .uploadBinary(
              filePath,
              _imageBytes!,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );

        avatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(filePath);

        debugPrint('Generated Public URL: $avatarUrl');
      }

      await Supabase.instance.client
          .from('users')
          .update({
            'username': _usernameController.text.trim(),
            'vibe_tags': _selectedTags,
            'avatar_url': avatarUrl,
          })
          .eq('id', user.id);

      await _fetchUserData();
      setState(() => _isEditing = false);
      Get.snackbar(
        'Success',
        'Profile updated!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      setState(() => _isSaving = false);
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
              SliverToBoxAdapter(
                child: MainHeader(
                  title: 'CAMPUS VIBE',
                  avatarUrl: _userData?['avatar_url'],
                  username: _userData?['username'],
                ),
              ),
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
                              isEditing: _isEditing,
                              usernameController: _usernameController,
                              selectedTags: _selectedTags,
                              imageBytes: _imageBytes,
                              upvotesCount: _upvotesCount,
                              aura: _aura,
                              onToggleEdit: _toggleEdit,
                              onPickImage: _pickImage,
                              onSave: _saveChanges,
                              onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                              isSaving: _isSaving,
                            );
                          } else {
                            return _MobileLayout(
                              userData: _userData,
                              isRevealHour: _isRevealHour,
                              isEditing: _isEditing,
                              usernameController: _usernameController,
                              selectedTags: _selectedTags,
                              imageBytes: _imageBytes,
                              upvotesCount: _upvotesCount,
                              aura: _aura,
                              onToggleEdit: _toggleEdit,
                              onPickImage: _pickImage,
                              onSave: _saveChanges,
                              onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                              isSaving: _isSaving,
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
  final bool isEditing;
  final VoidCallback? onPickImage;
  final Uint8List? imageBytes;

  const _HeroSection({
    this.userData,
    required this.isRevealHour,
    this.isMobile = false,
    this.isEditing = false,
    this.onPickImage,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        (userData?['avatar_url'] != null &&
            userData!['avatar_url'].toString().isNotEmpty) ||
        imageBytes != null;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Circular Profile Image
          GestureDetector(
            onTap: isEditing ? onPickImage : null,
            child: Container(
              width: isMobile ? 180 : 240,
              height: isMobile ? 180 : 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh,
                border: Border.all(
                  color: isEditing
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.2),
                  width: 4,
                ),
                image: hasAvatar
                    ? DecorationImage(
                        image: imageBytes != null
                            ? MemoryImage(imageBytes!)
                            : NetworkImage(userData!['avatar_url'])
                                  as ImageProvider,
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
              child: !hasAvatar
                  ? Icon(
                      isEditing
                          ? Icons.add_a_photo_rounded
                          : Icons.person_outline_rounded,
                      size: 80,
                      color: Colors.white10,
                    )
                  : (isEditing
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white70,
                              size: 40,
                            ),
                          )
                        : null),
            ),
          ),
          // Edit Pen Icon
          if (!isEditing)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isRevealHour;
  final bool isEditing;
  final TextEditingController usernameController;
  final List<String> selectedTags;
  final Uint8List? imageBytes;
  final int upvotesCount;
  final int aura;
  final VoidCallback onToggleEdit;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final Function(List<String>) onTagsChanged;
  final bool isSaving;

  const _MobileLayout({
    this.userData,
    required this.isRevealHour,
    required this.isEditing,
    required this.usernameController,
    required this.selectedTags,
    this.imageBytes,
    required this.upvotesCount,
    required this.aura,
    required this.onToggleEdit,
    required this.onPickImage,
    required this.onSave,
    required this.onTagsChanged,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (MediaQuery.of(context).size.width < 768)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: GlobalTopNav(),
          ),
        GestureDetector(
          onTap: onToggleEdit,
          child: _HeroSection(
            userData: userData,
            isRevealHour: isRevealHour,
            isMobile: true,
            isEditing: isEditing,
            onPickImage: onPickImage,
            imageBytes: imageBytes,
          ),
        ),
        const SizedBox(height: 48),
        _ContentSection(
          userData: userData,
          isEditing: isEditing,
          usernameController: usernameController,
          selectedTags: selectedTags,
          onSave: onSave,
          onCancel: onToggleEdit,
          onTagsChanged: onTagsChanged,
          isSaving: isSaving,
          upvotesCount: upvotesCount,
          aura: aura,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isRevealHour;
  final bool isEditing;
  final TextEditingController usernameController;
  final List<String> selectedTags;
  final Uint8List? imageBytes;
  final int upvotesCount;
  final int aura;
  final VoidCallback onToggleEdit;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final Function(List<String>) onTagsChanged;
  final bool isSaving;

  const _DesktopLayout({
    this.userData,
    required this.isRevealHour,
    required this.isEditing,
    required this.usernameController,
    required this.selectedTags,
    this.imageBytes,
    required this.upvotesCount,
    required this.aura,
    required this.onToggleEdit,
    required this.onPickImage,
    required this.onSave,
    required this.onTagsChanged,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: GestureDetector(
            onTap: onToggleEdit,
            child: _HeroSection(
              userData: userData,
              isRevealHour: isRevealHour,
              isEditing: isEditing,
              onPickImage: onPickImage,
              imageBytes: imageBytes,
            ),
          ),
        ),
        const SizedBox(width: 64),
        Expanded(
          flex: 5,
          child: _ContentSection(
            userData: userData,
            isEditing: isEditing,
            usernameController: usernameController,
            selectedTags: selectedTags,
            onSave: onSave,
            onCancel: onToggleEdit,
            onTagsChanged: onTagsChanged,
            isSaving: isSaving,
            upvotesCount: upvotesCount,
            aura: aura,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool isOutlined;

  const _Tag({required this.label, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined
            ? Colors.transparent
            : (AppColors.surfaceContainerHigh).withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isOutlined
              ? AppColors.onSurfaceVariant.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label(
          8,
          color: AppColors.onSurfaceVariant,
          weight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isEditing;
  final TextEditingController? usernameController;
  final List<String> selectedTags;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final Function(List<String>)? onTagsChanged;
  final bool isSaving;
  final int upvotesCount;
  final int aura;

  const _ContentSection({
    this.userData,
    this.isEditing = false,
    this.usernameController,
    this.selectedTags = const [],
    this.onSave,
    this.onCancel,
    this.onTagsChanged,
    this.isSaving = false,
    required this.upvotesCount,
    required this.aura,
  });

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
          if (isEditing)
            TextField(
              controller: usernameController,
              style: AppTextStyles.headline(60, weight: FontWeight.w900),
              decoration: const InputDecoration(
                hintText: 'USERNAME',
                border: InputBorder.none,
              ),
            )
          else
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
              if (isEditing)
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      ActivityPickerSheet(
                        initialSelected: selectedTags,
                        onSave: onTagsChanged ?? (_) {},
                      ),
                      isScrollControlled: true,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 16),
                        Text(
                          selectedTags.isEmpty
                              ? 'ADD YOUR CAMPUS ACTIVITIES'
                              : '${selectedTags.length} ACTIVITIES SELECTED',
                          style: AppTextStyles.label(12,
                              color: AppColors.primary, weight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              else if (selectedTags.isEmpty)
                Text(
                  'No activities selected yet.',
                  style: AppTextStyles.body(
                    18,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: selectedTags.map((tag) {
                    final activity = UniversityActivities.fromLabel(tag);
                    return ActivityChip(
                      label: tag,
                      icon: activity?.icon ?? '✨',
                      isCompact: true,
                    );
                  }).toList(),
                ),
              if (isEditing) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving ? null : onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('SAVE CHANGES'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: isSaving ? null : onCancel,
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatBadge(label: 'UPVOTES', value: upvotesCount.toString()),
                  _StatBadge(label: 'AURA', value: aura.toString()),
                  const _StatBadge(
                    label: 'STREAK',
                    value: '0',
                    isSecondary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isDesktop && isEditing) ...[
          const SizedBox(height: 24),
          TextField(
            controller: usernameController,
            style: AppTextStyles.headline(32, weight: FontWeight.w900),
            decoration: const InputDecoration(
              hintText: 'USERNAME',
              border: InputBorder.none,
            ),
          ),
        ],
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
                    image: NetworkImage(
                      [
                        'https://images.unsplash.com/photo-1535713222168-144b1393699c?w=500&q=80',
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
                        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&q=80',
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&q=80',
                        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80',
                      ][index % 5],
                    ),
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
