import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mainchar/screens/leaderboard_screen.dart';
import 'package:mainchar/screens/votes/voting_arena_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_pages.dart';
import 'controllers/auth_controller.dart';
import 'controllers/announcement_controller.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Ensure Google Fonts can be fetched at runtime
  GoogleFonts.config.allowRuntimeFetching = true;

  // Catch isolated Google Fonts network/loading errors to prevent app crashes.
  // When `allowRuntimeFetching` is true, a network error produces an unhandled
  // async exception safely ignored here, allowing a graceful fallback to system fonts.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (stack.toString().contains('google_fonts')) {
      debugPrint('Google Fonts failed to load: $error');
      return true; // Prevents the app from crashing
    }
    return false;
  };

  runApp(const MainCharApp());
}

class MainCharApp extends StatelessWidget {
  const MainCharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inside UoL',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(AnnouncementController(), permanent: true);
      }),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD394FF),
          secondary: Color(0xFFC3F400),
          tertiary: Color(0xFF00F4FE),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF0E0E0E),
          onPrimary: Color(0xFF000000),
          onSecondary: Color(0xFF354500),
          surfaceVariant: Color(0xFF262626),
          onSurfaceVariant: Color(0xFFADAAAA),
        ),
        textTheme: GoogleFonts.epilogueTextTheme()
            .copyWith(
              bodyLarge: GoogleFonts.plusJakartaSans(),
              labelLarge: GoogleFonts.spaceGrotesk(),
            )
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
