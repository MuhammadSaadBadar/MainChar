class Announcement {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String description;
  final String bannerUrl;
  final String eventDate;
  final String location;
  final String eventTime;
  final String status;
  final String rules;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    this.description = '',
    this.bannerUrl = '',
    this.eventDate = '',
    this.location = '',
    this.eventTime = '',
    this.status = 'pending',
    this.rules = '',
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      bannerUrl: json['banner_url'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      location: json['location'] as String? ?? '',
      eventTime: json['event_time'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      rules: json['rules'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'category': category,
      'description': description,
      'banner_url': bannerUrl,
      'event_date': eventDate,
      'location': location,
      'event_time': eventTime,
      'status': status,
      'rules': rules,
    };
  }

  bool get isLive {
    if (eventDate.isEmpty || eventTime.isEmpty) return true;
    try {
      final parts = eventDate.split('/');
      if (parts.length != 3) return true;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      String timeToParse = eventTime;
      if (eventTime.contains('-')) {
        timeToParse = eventTime.split('-').last.trim();
      }
      final timeParts = timeToParse.split(':');
      if (timeParts.length != 2) return true;
      final hour = int.parse(timeParts[0].trim());
      final minute = int.parse(timeParts[1].trim());

      final eventDateTime = DateTime(year, month, day, hour, minute);
      return DateTime.now().isBefore(eventDateTime);
    } catch (e) {
      return true; // fallback to showing it if parsing fails
    }
  }
}
