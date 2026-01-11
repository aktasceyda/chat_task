class BulletinPost {
  final int id;
  final String title;
  final String? subtitle;
  final String? coverPhoto;
  final String pathname;
  final String? createdAt;
  final int? readingTimeSeconds;

  BulletinPost({
    required this.id,
    required this.title,
    this.subtitle,
    this.coverPhoto,
    required this.pathname,
    this.createdAt,
    this.readingTimeSeconds,
  });

  factory BulletinPost.fromJson(Map<String, dynamic> json) {
    return BulletinPost(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      coverPhoto: json['cover_photo'] as String?,
      pathname: json['pathname'] as String,
      createdAt: json['created_at'] as String?,
      readingTimeSeconds: json['reading_time_seconds'] as int?,
    );
  }
}