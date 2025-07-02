import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/chatbot_fab.dart';
import 'provider/story_provider.dart';
import 'story_details_screen.dart';
import 'stories_list_screen.dart';
import '../learn/learn_screen.dart';
import '../../widgets/base_scaffold.dart';
import '../../providers/tip_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).loadLatestSavedStory();
      Provider.of<TipProvider>(context, listen: false).loadTipOfTheDay();
    });
  }

  void _openStoryDetails(BuildContext context, story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoryDetailsScreen(story: story)),
    );
  }

  Widget _buildTipOfTheDay() {
    return Consumer<TipProvider>(
      builder: (context, tipProvider, child) {
        if (tipProvider.isLoading) {
          return Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (tipProvider.error != null) {
          return Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tipProvider.error!),
                  if (tipProvider.error!.contains('Please log in'))
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
            ),
          );
        }

        final tip = tipProvider.tipOfTheDay;
        if (tip == null) {
          return Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text('No tip available')),
          );
        }

        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tip of the Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        tip.content,
                        style: TextStyle(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          await tipProvider.toggleLike();
                          // Clear the error after a short delay
                          if (tipProvider.error != null) {
                            Future.delayed(Duration(seconds: 3), () {
                              if (mounted) {
                                tipProvider.loadTipOfTheDay();
                              }
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              tip.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.purple,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${tip.likesCount}',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/tipoftheday.png',
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedStorySection() {
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        if (storyProvider.loading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 160,
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
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                ),
              ),
            ),
          );
        }

        final story = storyProvider.latestSavedStory;
        if (story == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 160,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No saved stories yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isSmall = constraints.maxWidth < 400;
                return isSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                              story.coverImage,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 160,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
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
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          storyProvider.toggleSave(story.id),
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
                                if (story.content.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      story.content,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            storyProvider.toggleLike(story.id),
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
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Color(0xFF7C3AED),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          minimumSize: Size(0, 28),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () =>
                                            _openStoryDetails(context, story),
                                        child: Text(
                                          'Read more',
                                          style: TextStyle(
                                            color: Color(0xFF7C3AED),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                story.coverImage,
                                width: 130,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 130,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          VerticalDivider(width: 1, color: Colors.grey[200]),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          story.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            storyProvider.toggleSave(story.id),
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
                                  if (story.content.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        story.content,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 4.0,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => storyProvider.toggleLike(
                                            story.id,
                                          ),
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
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                              color: Color(0xFF7C3AED),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            minimumSize: Size(0, 28),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () =>
                                              _openStoryDetails(context, story),
                                          child: Text(
                                            'Read more',
                                            style: TextStyle(
                                              color: Color(0xFF7C3AED),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      currentIndex: 0,
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
        child: ListView(
          padding: EdgeInsets.all(0),
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
                  Icon(Icons.home_outlined, color: Color(0xFF7C3AED), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/profile');
                    },
                    child: Icon(
                      Icons.account_circle_outlined,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Evening Pal!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  _buildTipOfTheDay(),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            'Let us Support you!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Emergency Help',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/report',
                              arguments: {'tab': 0},
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Report Case',
                            style: TextStyle(color: Colors.purple),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/report',
                              arguments: {'tab': 1},
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Community Chat',
                            style: TextStyle(color: Colors.purple),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/community');
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Quick Exit Settings',
                            style: TextStyle(color: Colors.purple),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/quick-exit-settings',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Continue Reading',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            _buildSavedStorySection(),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Community Corner',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StoriesListScreen()),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/gbvcommunity.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Text(
                        'GBV Community',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
