import 'package:flutter/material.dart';
import 'model/story_model.dart';
import 'provider/story_provider.dart';
import 'package:provider/provider.dart';

class StoryDetailsScreen extends StatefulWidget {
  final Story story;
  const StoryDetailsScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF7C3AED)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Story Details',
          style: TextStyle(color: Color(0xFF7C3AED)),
        ),
        actions: [
          Consumer<StoryProvider>(
            builder: (context, storyProvider, child) {
              return IconButton(
                icon: Icon(
                  widget.story.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: widget.story.isSaved
                      ? Color(0xFF7C3AED)
                      : Colors.black54,
                ),
                onPressed: () async {
                  await storyProvider.toggleSave(widget.story.id);
                  if (storyProvider.error?.contains('Please log in') ?? false) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Expanded(
                              child: Text('Please log in to save stories'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Color(0xFF7C3AED),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  'https://gbvfield.e-saloon.online/public/${widget.story.coverImage}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.story.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                Consumer<StoryProvider>(
                  builder: (context, storyProvider, child) {
                    return GestureDetector(
                      onTap: () async {
                        await storyProvider.toggleLike(widget.story.id);
                        if (storyProvider.error?.contains('Please log in') ??
                            false) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Please log in to like stories',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    child: Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFF7C3AED),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            widget.story.isLikedByUser
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 24,
                            color: widget.story.isLikedByUser
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.story.likesCount.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              widget.story.content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Posted on ${widget.story.createdAt.day}/${widget.story.createdAt.month}/${widget.story.createdAt.year}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
