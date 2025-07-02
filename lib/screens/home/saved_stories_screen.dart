import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/story_model.dart';
import 'provider/story_provider.dart';
import 'story_details_screen.dart';

class SavedStoriesScreen extends StatefulWidget {
  const SavedStoriesScreen({Key? key}) : super(key: key);

  @override
  State<SavedStoriesScreen> createState() => _SavedStoriesScreenState();
}

class _SavedStoriesScreenState extends State<SavedStoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadSavedStories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSavedStories() {
    Provider.of<StoryProvider>(context, listen: false).loadSavedStories();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      Provider.of<StoryProvider>(
        context,
        listen: false,
      ).loadMoreSavedStories().then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  void _openStoryDetails(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoryDetailsScreen(story: story)),
    );
  }

  Widget _buildStoryCard(Story story, StoryProvider storyProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () => _openStoryDetails(context, story),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    story.coverImage,
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            story.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => storyProvider.toggleSave(story.id),
                          child: Icon(
                            story.isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: story.isSaved
                                ? Color(0xFF7C3AED)
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      story.content,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => storyProvider.toggleLike(story.id),
                          child: Row(
                            children: [
                              Icon(
                                story.isLikedByUser
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: story.isLikedByUser
                                    ? Colors.red
                                    : Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                story.likesCount.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Posted on ${story.createdAt.day}/${story.createdAt.month}/${story.createdAt.year}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF7C3AED)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Stories',
          style: TextStyle(color: Color(0xFF7C3AED)),
        ),
      ),
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          if (storyProvider.initialLoadingSaved) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              ),
            );
          }

          if (storyProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(storyProvider.error!),
                  if (storyProvider.error!.contains('Please log in'))
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          final savedStories = storyProvider.savedStories;
          if (savedStories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved stories yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Text(
                      'Browse Stories',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 16),
            itemCount: savedStories.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == savedStories.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                );
              }
              return _buildStoryCard(savedStories[index], storyProvider);
            },
          );
        },
      ),
    );
  }
}
