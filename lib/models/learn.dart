import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'learn_category.dart';

class Learn {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final String? youtubeUrl;
  final String? imagePath;
  final String? url;
  final int likesCount;
  final bool isLiked;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  LearnCategory? category;

  Learn({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    this.youtubeUrl,
    this.imagePath,
    this.url,
    required this.likesCount,
    this.isLiked = false,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  String get fullImageUrl {
    if (imagePath == null) return '';
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanImagePath = imagePath!.startsWith('/')
        ? imagePath!.substring(1)
        : imagePath!;
    return '$cleanBaseUrl/$cleanImagePath';
  }

  factory Learn.fromJson(Map<String, dynamic> json) {
    return Learn(
      id: json['id'],
      categoryId: json['category_id'],
      title: json['title'],
      content: json['content'],
      youtubeUrl: json['youtube_url'],
      imagePath: json['image_path'],
      url: json['url'],
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '') ?? 0,
      isLiked: json['liked_by_users']?.isNotEmpty ?? false,
      isRead: json['read_by_users']?.isNotEmpty ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: json['category'] != null
          ? LearnCategory.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'content': content,
      'youtube_url': youtubeUrl,
      'image_path': imagePath,
      'url': url,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category?.toJson(),
    };
  }
}
