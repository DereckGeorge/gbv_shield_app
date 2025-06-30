import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/learn.dart';
import '../../providers/learn_provider.dart';
import '../../widgets/base_scaffold.dart';
import '../home/home_screen.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';
import 'webview_screen.dart';
import 'learn_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch learns when the screen is first initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LearnProvider>(context, listen: false).loadLearns();
    });
  }

  Widget _buildLearnItem(Learn learn) {
    String? videoId;
    if (learn.youtubeUrl != null && learn.youtubeUrl!.isNotEmpty) {
      videoId = YoutubePlayer.convertUrlToId(learn.youtubeUrl!);
    }

    return GestureDetector(
      onTap: () {
        if (videoId != null) {
          // If it's a video, open the YouTube player directly
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  YoutubePlayerScreen(videoId: videoId!, title: learn.title),
            ),
          );
        } else if (learn.url != null && learn.url!.isNotEmpty) {
          // If it's an article with a URL, open the WebView screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  WebViewScreen(url: learn.url!, title: learn.title),
            ),
          );
        } else {
          // As a fallback for articles with no URL, open the detail screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LearnDetailScreen(learn: learn)),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: videoId != null
                      ? Image.network(
                          'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : learn.imagePath != null
                      ? Image.network(
                          learn.fullImageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                if (videoId != null)
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 60,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (learn.category != null)
                    Text(
                      learn.category!.name.toUpperCase(),
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  SizedBox(height: 8),
                  Text(
                    learn.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    learn.content,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${learn.likesCount} likes',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Spacer(),
                      Text(
                        learn.createdAt.toString().split(' ')[0],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey[500]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      currentIndex: 1,
      onTab: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (i == 1) {
          // Already on learn
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, '/report');
        } else if (i == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    color: Color(0xFF7C3AED),
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Learn',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search resources...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Consumer<LearnProvider>(
                builder: (context, learnProvider, child) {
                  if (learnProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (learnProvider.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Error: ${learnProvider.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final filteredList = learnProvider.learns.where((learn) {
                    final query = _searchQuery.toLowerCase();
                    return learn.title.toLowerCase().contains(query) ||
                        learn.content.toLowerCase().contains(query) ||
                        (learn.category?.name.toLowerCase().contains(query) ??
                            false);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(child: Text('No resources found.'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildLearnItem(filteredList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
