import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../widgets/base_scaffold.dart';
import '../home/home_screen.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';
import 'webview_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String search = '';
  @override
  Widget build(BuildContext context) {
    final materials = [
      {
        'type': 'video',
        'category': 'Sexual Health',
        'title': 'Understanding Consent',
        'description':
            'A comprehensive guide to understanding consent in relationships and daily interactions.',
        'date': '10 Feb, 2018',
        'author': 'Amaze.org',
        'likes': 128,
        'url': 'https://youtu.be/4z9_L9FXA3o?si=QaX2ONrcEMkAhvUY',
        'thumbnail': 'assets/consent.png',
      },
      {
        'type': 'article',
        'category': 'GBV Prevention',
        'title':
            'Recognizing the Signs: Understanding Different Forms of Abuse',
        'description':
            'Learn to identify warning signs of different types of abuse and how to respond appropriately.',
        'date': '6 Aug, 2024',
        'author': 'Michael Lee',
        'likes': 128,
        'url':
            'https://www.ncacia.org/post/recognizing-the-signs-understanding-different-forms-of-abuse',
        'thumbnail': 'assets/caution.png',
      },
      {
        'type': 'article',
        'category': 'Sexual Health',
        'title': "Zawada's Story: How Smart Choices Can Shape Your Future",
        'description':
            'At just 19, Zawada from Morogoro was unsure of her future—until she found a youth-friendly health center that listened, guided, and supported her choices.',
        'date': '',
        'author': '',
        'likes': 128,
        'url':
            'https://international-partnerships.ec.europa.eu/news-and-events/stories/empowering-young-people-their-sexual-health-choices-tanzania_en',
        'thumbnail': 'assets/zawada.png',
      },
    ];
    final filtered = materials.where((mat) {
      final q = search.toLowerCase();
      return (mat['title'] as String).toLowerCase().contains(q) ||
          (mat['description'] as String).toLowerCase().contains(q) ||
          (mat['category'] as String).toLowerCase().contains(q);
    }).toList();
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
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 8),
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
                      onChanged: (v) => setState(() => search = v),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: Text('Filters'),
                  ),
                ],
              ),
            ),
            ...filtered.map(
              (mat) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final url = mat['url'] as String;
                    if (mat['type'] == 'video' && url.contains('youtube.com')) {
                      final videoId =
                          Uri.parse(url).queryParameters['v'] ??
                          YoutubePlayer.convertUrlToId(url) ??
                          '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YoutubePlayerScreen(
                            videoId: videoId,
                            title: mat['title'] as String,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewScreen(
                            url: url,
                            title: mat['title'] as String,
                          ),
                        ),
                      );
                    }
                  },
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
                              child: Image.asset(
                                mat['thumbnail'] as String,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
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
                                  mat['category'] as String,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            if (mat['type'] == 'video')
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Text(
                            mat['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            mat['description'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Row(
                            children: [
                              if ((mat['date'] as String).isNotEmpty)
                                Text(
                                  mat['date'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              if ((mat['author'] as String).isNotEmpty) ...[
                                SizedBox(width: 8),
                                Text(
                                  'By ${mat['author']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                color: Colors.purple,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${mat['likes']}',
                                style: TextStyle(color: Colors.black54),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () async {
                                  final url = Uri.parse(mat['url'] as String);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: Text('Mark as read'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
