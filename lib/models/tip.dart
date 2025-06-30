class Tip {
  final String id;
  final String title;
  final String content;
  final int likesCount;
  final bool isLiked;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '') ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }
} 