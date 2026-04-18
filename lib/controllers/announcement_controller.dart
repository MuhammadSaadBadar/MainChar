import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';

class AnnouncementController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Real-time streams
  final RxList<Announcement> pendingRequests = <Announcement>[].obs;
  final RxList<Announcement> approvedAnnouncements = <Announcement>[].obs;

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
            print(
              '[AnnouncementController] Received ${data.length} items from stream',
            );
            try {
              final List<Announcement> all = data.map((json) {
                try {
                  return Announcement.fromJson(json);
                } catch (e) {
                  print(
                    '[AnnouncementController] Error parsing announcement: $e',
                  );
                  print('[AnnouncementController] JSON data: $json');
                  rethrow;
                }
              }).toList();

              print(
                '[AnnouncementController] Parsed ${all.length} announcements successfully',
              );

              final pending = all.where((e) => e.status == 'pending').toList();
              final approved = all
                  .where((e) => e.status == 'approved')
                  .toList();

              print(
                '[AnnouncementController] Pending: ${pending.length}, Approved: ${approved.length}',
              );

              pendingRequests.assignAll(pending);
              approvedAnnouncements.assignAll(approved);
            } catch (e) {
              print('[AnnouncementController] Mapping error: $e');
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
    _listenToAnnouncements();
  }
}
