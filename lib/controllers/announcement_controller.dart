import 'dart:async';
import 'package:get/get.dart';
import 'package:mainchar/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';

class AnnouncementController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Real-time streams
  final RxList<Announcement> pendingRequests = <Announcement>[].obs;
  final RxList<Announcement> approvedAnnouncements = <Announcement>[].obs;
  final RxList<Announcement> historyAnnouncements = <Announcement>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAnnouncements();
  }

  StreamSubscription? _subscription;

  void _listenToAnnouncements() {
    // Stream for all announcements (RLS filters what each user sees)
    _subscription = _supabase
        .from('event_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen(
          (data) {
            print('[AnnouncementController] Stream update: ${data.length} raw items');
            try {
              final List<Announcement> all = [];
              for (var json in data) {
                try {
                  all.add(Announcement.fromJson(json));
                } catch (e) {
                  print('[AnnouncementController] Skipping malformed announcement (ID: ${json['id']}): $e');
                }
              }

              print('[AnnouncementController] Parsed ${all.length} announcements');

              final pending = all.where((e) => e.status == 'pending').toList();
              final history = all.where((e) => e.status != 'pending').toList();
              final approved = all
                  .where((e) => e.status == 'approved' && e.isLive)
                  .toList();

              print('[AnnouncementController] Filtered -> Pending: ${pending.length}, Approved: ${approved.length}, History: ${history.length}');

              pendingRequests.assignAll(pending);
              approvedAnnouncements.assignAll(approved);
              historyAnnouncements.assignAll(history);
              _updateUnreadCount();
            } catch (e) {
              print('[AnnouncementController] Critical error in stream processing: $e');
            }
          },
          onError: (error) {
            print('[AnnouncementController] Stream error: $error');
          },
        );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> submitRequest({
    required String title,
    required String category,
    required String description,
    required String location,
    required String eventDate,
    required String eventTime,
    required String rules,
    String? bannerUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('event_requests').insert({
      'user_id': userId,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'event_date': eventDate,
      'event_time': eventTime,
      'rules': rules,
      'banner_url': bannerUrl ?? '',
      'status': 'pending',
    });
  }

  Future<void> updateStatus(String id, String status) async {
    print('[AnnouncementController] Updating status of $id to $status');
    try {
      final response = await _supabase
          .from('event_requests')
          .update({'status': status})
          .eq('id', id)
          .select();

      print('[AnnouncementController] Update response: $response');
      if (response == null || response.isEmpty) {
        print('[AnnouncementController] Warning: No rows were updated.');
      }
    } catch (e) {
      print('[AnnouncementController] Update error: $e');
      rethrow;
    }
  }

  void refreshAnnouncements() {
    print('[AnnouncementController] Manual refresh triggered');
    _subscription?.cancel();
    pendingRequests.clear();
    approvedAnnouncements.clear();
    historyAnnouncements.clear();
    _listenToAnnouncements();
  }

  void _updateUnreadCount() {
    try {
      final auth = Get.find<AuthController>();
      final lastCheckStr = auth.userProfile['last_announcement_check'];
      if (lastCheckStr == null) {
        unreadCount.value = approvedAnnouncements.length;
        return;
      }

      final lastCheck = DateTime.parse(lastCheckStr.toString());
      unreadCount.value = approvedAnnouncements
          .where((a) => a.createdAt.isAfter(lastCheck))
          .length;
      print('[AnnouncementController] Unread count: ${unreadCount.value}');
    } catch (e) {
      print('[AnnouncementController] Error updating unread count: $e');
    }
  }

  Future<void> markAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now().toIso8601String();
    try {
      await _supabase
          .from('users')
          .update({'last_announcement_check': now})
          .eq('id', userId);

      // Update local state immediately
      Get.find<AuthController>().userProfile['last_announcement_check'] = now;
      unreadCount.value = 0;
      print('[AnnouncementController] Marked as read at $now');
    } catch (e) {
      print('[AnnouncementController] Error marking as read: $e');
    }
  }
}
