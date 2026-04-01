import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _meshController;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Mesh Gradients Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _meshController,
              builder: (context, child) {
                final animValue = _meshController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        math.cos(animValue * 2 * math.pi) * 0.3,
                        math.sin(animValue * 2 * math.pi) * 0.3,
                      ),
                      colors: [
                        const Color(0xFF4A0076).withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ).animate();
              },
            ),
          ),
          // Noise Overlay
          Positioned.fill(child: CustomPaint(painter: NoisePainter())),
          // Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Verification Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF20201F),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF484847,
                                      ).withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFFC3F400),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '.EDU VERIFIED EXCLUSIVE',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 500.ms).scale(),
                                const SizedBox(height: 48),
                                // Hero Branding
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'CAMPUS\n',
                                        style: GoogleFonts.epilogue(
                                          fontSize: constraints.maxWidth > 600
                                              ? 80
                                              : 60,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFC3F400),
                                          letterSpacing: -2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'VIBE',
                                        style: GoogleFonts.epilogue(
                                          fontSize: constraints.maxWidth > 600
                                              ? 80
                                              : 60,
                                          fontWeight: FontWeight.w900,
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFFC3F400),
                                          letterSpacing: -2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fadeIn(
                                  delay: 300.ms,
                                  duration: 800.ms,
                                ),
                                const SizedBox(height: 32),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    'Step into the spotlight. The university experience, reimagined for the next generation of legends.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      height: 1.5,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ).animate().fadeIn(
                                  delay: 500.ms,
                                  duration: 800.ms,
                                ),
                                const SizedBox(height: 64),
                                // CTA
                                SizedBox(
                                      width: double.infinity,
                                      height: 70,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFC3F400,
                                          ),
                                          foregroundColor: Colors.black,
                                          shape: const StadiumBorder(),
                                          elevation: 0,
                                          shadowColor: const Color(
                                            0xFFC3F400,
                                          ).withOpacity(0.3),
                                        ),
                                        onPressed:
                                            () {}, // Handled by GetX routing
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Be the Main Character',
                                              style: GoogleFonts.epilogue(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.trending_flat),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 700.ms)
                                    .scale(duration: 600.ms),
                                const SizedBox(height: 32),
                                // Avatars Stack + Stats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        _buildAvatar(
                                          'https://via.placeholder.com/40/4A0076/ffffff?text=1',
                                        ),
                                        Positioned(
                                          left: 20,
                                          child: _buildAvatar(
                                            'https://via.placeholder.com/40/CB80FF/ffffff?text=2',
                                          ),
                                        ),
                                        Positioned(
                                          left: 40,
                                          child: _buildAvatar(
                                            'https://via.placeholder.com/40/D394FF/ffffff?text=3',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    Text(
                                      '12k+ students active now',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD394FF),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 900.ms),
                              ],
                            ),
                          ),
                          // Footer
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Support',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          letterSpacing: 2,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Privacy',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          letterSpacing: 2,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Terms',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          letterSpacing: 2,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'CAMPUS VIBE',
                                  style: GoogleFonts.epilogue(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFFC3F400),
                                  ),
                                ),
                                Text(
                                  '© 2024 MAIN CHARACTER ENERGY. .EDU VERIFIED.',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    letterSpacing: 3,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ).animate().fadeIn(delay: 1200.ms),
                                const SizedBox(height: 48),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF0E0E0E), width: 2),
        ),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF4A0076),
            child: const Icon(Icons.person, color: Colors.white54),
          ),
        ),
      ),
    ).animate();
  }
}

class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 500; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
