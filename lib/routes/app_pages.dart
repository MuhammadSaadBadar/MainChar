import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/voting_arena_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/explore_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.ARENA,
      page: () => const VotingArenaScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.LEADERBOARD,
      page: () => const LeaderboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.EXPLORE,
      page: () => const ExploreScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
