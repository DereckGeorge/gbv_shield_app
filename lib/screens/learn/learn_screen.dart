import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../providers/learn_provider.dart';
import '../../widgets/base_scaffold.dart';
import '../../models/learn.dart';
import '../../models/learn_category.dart';
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
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final learnProvider = Provider.of<LearnProvider>(context, listen: false);
    learnProvider.loadCategories();
    learnProvider.loadLearns(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<LearnProvider>(context, listen: false).loadLearns();
    }
  }

  Widget _buildMediaPreview(Learn learn) {
    if (learn.youtubeUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(learn.youtubeUrl!);
      if (videoId != null) {
        return Stack(
          children: [
            Image.network(
              'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.network(
                'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: Icon(Icons.play_circle_outline, size: 50),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }

    if (learn.imagePath != null) {
      return Image.network(
        learn.fullImageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 160,
          color: Colors.grey[300],
          child: Icon(Icons.image),
        ),
      );
    }

    return Container(
      height: 160,
      color: Colors.grey[300],
      child: Icon(Icons.article),
    );
  }

  void _handleLearnTap(BuildContext context, Learn learn) async {
    try {
      await Provider.of<LearnProvider>(context, listen: false).markAsRead(learn.id);
      
      // Navigate to the detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LearnDetailScreen(learn: learn),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      currentIndex: 1,
      onTab: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (i == 1) {
          Navigator.pushReplacementNamed(context, '/learn');
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, '/report');
        } else if (i == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      child: SafeArea(
        child: Consumer<LearnProvider>(
          builder: (context, learnProvider, _) {
            return Column(
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            // TODO: Implement search functionality
                          },
                      decoration: InputDecoration(
                        hintText: 'Search resources...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                      PopupMenuButton<String?>(
                        initialValue: learnProvider.selectedCategoryId,
                        child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                learnProvider.selectedCategoryId == null
                                    ? 'All Categories'
                                    : learnProvider.categories
                                        .firstWhere(
                                          (cat) => cat.id == learnProvider.selectedCategoryId,
                                          orElse: () => LearnCategory(
                                            id: '',
                                            name: 'All Categories',
                                            createdAt: DateTime.now(),
                                            updatedAt: DateTime.now(),
                                          ),
                                        )
                                        .name,
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<String?>(
                            value: null,
                            onTap: () => learnProvider.selectCategory(null),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.clear_all,
                                  color: learnProvider.selectedCategoryId == null
                                      ? Color(0xFF7C3AED)
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'All Categories',
                                  style: TextStyle(
                                    color: learnProvider.selectedCategoryId == null
                                        ? Color(0xFF7C3AED)
                                        : Colors.black,
                                    fontWeight: learnProvider.selectedCategoryId == null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...learnProvider.categories.map(
                            (category) => PopupMenuItem<String?>(
                              value: category.id,
                              onTap: () => learnProvider.selectCategory(category.id),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    color: category.id == learnProvider.selectedCategoryId
                                        ? Color(0xFF7C3AED)
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      color: category.id == learnProvider.selectedCategoryId
                                          ? Color(0xFF7C3AED)
                                          : Colors.black,
                                      fontWeight: category.id == learnProvider.selectedCategoryId
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),
                if (learnProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      learnProvider.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => learnProvider.loadLearns(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: learnProvider.learns.length + (learnProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == learnProvider.learns.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final learn = learnProvider.learns[index];
                        return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: GestureDetector(
                            onTap: () => _handleLearnTap(context, learn),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                                        child: _buildMediaPreview(learn),
                                      ),
                                      if (learn.category != null)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                              learn.category!.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          learn.title,
                            style: TextStyle(
                                            fontSize: 18,
                              fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          learn.content,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                            children: [
                                Text(
                                              learn.createdAt.toString().split(' ')[0],
                                  style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Spacer(),
                                            IconButton(
                                              icon: Icon(
                                                learn.isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: learn.isLiked
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await learnProvider.toggleLike(learn.id);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(e.toString())),
                                                  );
                                                }
                                              },
                                            ),
                                Text(
                                              learn.likesCount.toString(),
                                  style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            TextButton.icon(
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
                                              icon: Icon(
                                                learn.isRead ? Icons.check_circle : Icons.check_circle_outline,
                                                color: learn.isRead ? Colors.green : Colors.grey,
                                                size: 20,
                                              ),
                                              label: Text(
                                                'Mark as read',
                                                style: TextStyle(
                                                  color: learn.isRead ? Colors.green : Colors.grey,
                                                ),
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
                      },
                ),
              ),
            ),
          ],
            );
          },
        ),
      ),
    );
  }
}
