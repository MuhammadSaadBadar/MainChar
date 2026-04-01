import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VotingArenaScreen extends StatefulWidget {
  const VotingArenaScreen({super.key});

  @override
  State<VotingArenaScreen> createState() => _VotingArenaScreenState();
}

class _VotingArenaScreenState extends State<VotingArenaScreen> {
  final CardSwiperController _controller = CardSwiperController();
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch IDs of users already voted on
      final votedResponse = await Supabase.instance.client
          .from('votes')
          .select('target_id')
          .eq('voter_id', user.id);

      final votedIds = (votedResponse as List)
          .map((v) => v['target_id'] as String)
          .toList();

      // 2. Fetch profiles not in that list and not self
      var query = Supabase.instance.client
          .from('users')
          .select('*')
          .neq('id', user.id);

      if (votedIds.isNotEmpty) {
        query = query.not('id', 'in', votedIds);
      }

      final profilesResponse = await query;

      setState(() {
        _profiles = List<Map<String, dynamic>>.from(profilesResponse);
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final targetProfile = _profiles[previousIndex];
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return false;

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arena',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.leaderboard_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _profiles.isEmpty
                        ? Center(
                            child: Text(
                              'No more profiles!',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : CardSwiper(
                            controller: _controller,
                            cardsCount: _profiles.length,
                            onSwipe: _onSwipe,
                            numberOfCardsDisplayed: _profiles.length == 1 ? 1 : (_profiles.length == 2 ? 2 : 3),
                            padding: const EdgeInsets.all(24.0),
                            cardBuilder:
                                (
                                  context,
                                  index,
                                  horizontalThresholdPercentage,
                                  verticalThresholdPercentage,
                                ) {
                                  final profile = _profiles[index];
                                  return _buildProfileCard(profile);
                                },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      color: Colors.redAccent,
                      onTap: () => _controller.swipe(CardSwiperDirection.left),
                    ),
                    _buildActionButton(
                      icon: Icons.favorite,
                      color: const Color(0xFFE94057),
                      onTap: () => _controller.swipe(CardSwiperDirection.right),
                      isLarge: true,
                    ),
                    _buildActionButton(
                      icon: Icons.refresh,
                      color: Colors.blueAccent,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            profile['avatar_url'] ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.person, size: 80, color: Colors.white24),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['username'] ?? 'User',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile['bio']!,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: isLarge ? 35 : 25),
      ),
    );
  }
}
