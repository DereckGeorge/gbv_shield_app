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

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      coverImage: json['cover_image'],
      likesCount: json['likes_count'] ?? 0,
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
 