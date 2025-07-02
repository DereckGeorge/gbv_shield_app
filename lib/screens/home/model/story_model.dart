import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Story {
  final String id;
  final String title;
  final String content;
  final String coverImage;
  final int likesCount;
  final bool isLikedByUser;
  final bool isSaved;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.coverImage,
    required this.likesCount,
    required this.isLikedByUser,
    required this.isSaved,
    required this.createdAt,
  });

  String get fullCoverImageUrl {
    if (coverImage.isEmpty) {
      return '';
    }
    // Check if the coverImage is already a full URL
    if (coverImage.startsWith('http')) {
      return coverImage;
    }

    final baseUrl = dotenv.env['API_BASE_URL'];

    // If baseUrl is missing, log an error and return an empty string
    // to prevent a crash and show a placeholder image.
    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint(
        "--- DEBUG WARNING: API_BASE_URL not found in .env file. "
        "Image URLs will be invalid. ---",
      );
      return ''; // Return empty string to trigger errorBuilder
    }

    // --- NEW DEBUGGING STEP ---
    debugPrint("--- Image Debug: Base URL from .env: '$baseUrl'");
    debugPrint("--- Image Debug: Cover image path: '$coverImage'");

    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanImagePath = coverImage.startsWith('/')
        ? coverImage.substring(1)
        : coverImage;

    final finalUrl = '$cleanBaseUrl/$cleanImagePath';

    // --- NEW DEBUGGING STEP ---
    debugPrint("--- Image Debug: Final constructed URL: '$finalUrl'");

    return finalUrl;
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      coverImage: json['cover_image'] ?? '',
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
      isSaved: json['is_saved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Story copyWith({
    String? id,
    String? title,
    String? content,
    String? coverImage,
    int? likesCount,
    bool? isLikedByUser,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImage: coverImage ?? this.coverImage,
      likesCount: likesCount ?? this.likesCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
