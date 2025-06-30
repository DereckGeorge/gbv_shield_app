import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/learn.dart';
import '../../providers/learn_provider.dart';
import 'youtube_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'webview_screen.dart';

class LearnDetailScreen extends StatelessWidget {
  final Learn learn;

  const LearnDetailScreen({Key? key, required this.learn}) : super(key: key);

  Widget _buildMediaContent() {
    String? videoId;

    if (learn.youtubeUrl != null && learn.youtubeUrl!.isNotEmpty) {
      videoId = YoutubePlayer.convertUrlToId(learn.youtubeUrl!);
    }

    if (videoId != null) {
      return GestureDetector(
        onTap: () {
          // Ensure context is available before navigating
          if (navigatorKey.currentContext != null) {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (_) =>
                    YoutubePlayerScreen(videoId: videoId!, title: learn.title),
              ),
            );
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              // Use hqdefault first as it's more reliable
              'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback for when even hqdefault fails
                return Container(
                  height: 240,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
            // Play button overlay
            Container(
              height: 240,
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (learn.imagePath != null) {
      return Image.network(
        learn.fullImageUrl,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 240,
          color: Colors.grey[300],
          child: Icon(Icons.image, size: 64),
        ),
      );
    }

    return Container(
      height: 240,
      color: Colors.grey[300],
      child: Icon(Icons.article, size: 64),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LearnProvider>(
        builder: (context, learnProvider, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildMediaContent(),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        learn.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: learn.isLiked ? Colors.red : Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await learnProvider.toggleLike(learn.id);
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                  SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (learn.category != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            learn.category!.name,
                            style: TextStyle(
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      Text(
                        learn.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            learn.createdAt.toString().split(' ')[0],
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.favorite, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${learn.likesCount} likes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        learn.content,
                        style: TextStyle(fontSize: 16, height: 1.6),
                      ),
                      SizedBox(height: 32),
                      if (learn.url != null &&
                          (learn.youtubeUrl == null ||
                              learn.youtubeUrl!.isEmpty))
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (navigatorKey.currentContext != null) {
                                Navigator.push(
                                  navigatorKey.currentContext!,
                                  MaterialPageRoute(
                                    builder: (_) => WebViewScreen(
                                      url: learn.url!,
                                      title: learn.title,
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.open_in_new),
                            label: Text('View Full Article'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 32),
                      if (!learn.isRead)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await learnProvider.markAsRead(learn.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Marked as read'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            icon: Icon(Icons.check_circle_outline),
                            label: Text('Mark as read'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      if (learn.isRead)
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Marked as read',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Add this at the top level of the file
final navigatorKey = GlobalKey<NavigatorState>();
