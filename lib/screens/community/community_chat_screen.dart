import 'package:flutter/material.dart';

class CommunityChatScreen extends StatelessWidget {
  const CommunityChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock admin posts
    final List<Map<String, dynamic>> posts = [
      {
        'user': 'You are Beautiful',
        'image': 'assets/zawada.png',
        'question': 'Do you feel comfortable going out make-up free?',
        'likes': 35600,
        'comments': 19400,
        'comment':
            "I used to feel like I would never be able to leave the house without makeup. In fact I never did! But then this one time, I met a friend that had never worn makeup. I was very shocked not that she isn't beautiful, infact she is extremely beautiful! But I ...",
      },
      {
        'user': 'Mental Health',
        'image': 'assets/zawada.png',
        'question': 'Ever been Bodyshamed? How did you cope?',
        'likes': 12000,
        'comments': 8000,
        'comment':
            'Body shaming is so common. I learned to love myself and ignore the negativity. Surround yourself with positive people!',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Chat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, idx) {
          final post = posts[idx];
          return Card(
            margin: EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
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
                        post['image'] as String,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        post['question'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black54),
                          ],
                        ),
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
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.purple,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              post['user'] as String,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Text(
                            'Follow',
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.more_vert, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.purple),
                      SizedBox(width: 4),
                      Text(
                        '${(post['likes'] as int?) != null ? (post['likes'] as int) ~/ 1000 : 0}K',
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.comment_outlined, color: Colors.purple),
                      SizedBox(width: 4),
                      Text(
                        '${(post['comments'] as int?) != null ? (post['comments'] as int) ~/ 1000 : 0}K',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    post['comment'] as String,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View all ${(post['comments'] as int?) != null ? (post['comments'] as int) ~/ 1000 : 0}K comments',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
