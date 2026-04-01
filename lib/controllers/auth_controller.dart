import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    _listenAuthChanges();
  }

  @override
  void onReady() {
    super.onReady();
    _initialRedirect();
  }

  void _listenAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.event == AuthChangeEvent.signedIn) {
        _initialRedirect();
      } else if (data.event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    });
  }

  Future<void> _initialRedirect() async {
    isLoading.value = true;
    final user = _supabase.auth.currentUser;

    if (user == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
      isLoading.value = false;
      return;
    }

    try {
      // Check if user exists in our DB
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        // No profile found
        Get.offAllNamed(AppRoutes.PROFILE_SETUP);
      } else {
        // Profile found
        Get.offAllNamed(AppRoutes.NAV);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Delete from users table (Cascade will handle votes due to SQL schema)
      await _supabase.from('users').delete().eq('id', user.id);
      
      // 2. Sign out
      await signOut();
      
      Get.snackbar('Account Deleted', 'Your data has been removed.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e');
    }
  }
}
