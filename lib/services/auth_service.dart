import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Signs up a new user with email, password, and username.
  /// Enforces @cuilahore.edu.pk email domain.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // 1. Validate domain
    if (!email.toLowerCase().endsWith('@cuilahore.edu.pk')) {
      throw Exception('Only @cuilahore.edu.pk emails are allowed!');
    }

    // 2. Sign up with Supabase
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username,
      },
      emailRedirectTo: 'mainchar://login-callback',
    );

    return response;
  }

  /// Signs in a user with email and password.
  /// Enforces @cuilahore.edu.pk email domain.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Validate domain
    if (!email.toLowerCase().endsWith('@cuilahore.edu.pk')) {
      throw Exception('Only @cuilahore.edu.pk emails are allowed!');
    }

    // 2. Sign in with Supabase
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sends a password reset email if the user exists and matches the domain.
  Future<void> sendPasswordResetEmail(String email) async {
    if (!email.toLowerCase().endsWith('@cuilahore.edu.pk')) {
      throw Exception('Only @cuilahore.edu.pk emails are allowed!');
    }
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'mainchar://reset-password',
    );
  }

  /// Verifies the OTP sent to the user's email.
  Future<AuthResponse> verifyOTP(String email, String otp) async {
    return await _supabase.auth.verifyOTP(
      email: email.trim(),
      token: otp.trim(),
      type: OtpType.magiclink,
    );
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Returns the currently logged in user, or null.
  User? get currentUser => _supabase.auth.currentUser;
}
