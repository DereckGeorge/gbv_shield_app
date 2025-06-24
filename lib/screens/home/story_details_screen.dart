import 'package:flutter/material.dart';
import 'model/story_model.dart';

class StoryDetailsScreen extends StatelessWidget {
  final Story story;
  const StoryDetailsScreen({Key? key, required this.story}) : super(key: key);

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
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              story.imageAsset,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 24),
          Text(
            story.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          SizedBox(height: 12),
          Text(
            story.description,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
