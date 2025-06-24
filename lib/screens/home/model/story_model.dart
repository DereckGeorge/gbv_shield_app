class Story {
  final String title;
  final String description;
  final String imageAsset;
  final String? buttonText;

  Story({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.buttonText,
  });
}
