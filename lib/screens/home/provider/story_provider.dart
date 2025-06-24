import 'package:flutter/material.dart';
import '../model/story_model.dart';
import '../service/story_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  List<Story> _stories = [];
  bool _loading = false;

  List<Story> get stories => _stories;
  bool get loading => _loading;

  Future<void> loadStories() async {
    _loading = true;
    notifyListeners();
    _stories = await _storyService.fetchStories();
    _loading = false;
    notifyListeners();
  }
}
