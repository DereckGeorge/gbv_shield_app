import 'package:flutter/material.dart';
import '../model/story_model.dart';
import '../service/story_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  Story? _latestSavedStory;
  List<Story> _stories = [];
  List<Story> _savedStories = [];
  bool _loading = false;
  bool _initialLoading = true;
  bool _initialLoadingSaved = true;
  String? _error;
  int _currentPage = 1;
  int _savedStoriesPage = 1;
  bool _hasMorePages = true;
  bool _hasMoreSavedPages = true;

  Story? get latestSavedStory => _latestSavedStory;
  List<Story> get stories => _stories;
  List<Story> get savedStories => _savedStories;
  bool get loading => _loading;
  bool get initialLoading => _initialLoading;
  bool get initialLoadingSaved => _initialLoadingSaved;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  bool get hasMoreSavedPages => _hasMoreSavedPages;

  Future<void> loadLatestSavedStory() async {
    if (_loading) return;
    
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _latestSavedStory = await _storyService.fetchLatestSavedStory();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved story';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadStories() async {
    if (_loading) return;
    
    _initialLoading = true;
    _error = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await _storyService.fetchStories(_currentPage);
      _stories = response.stories;
      _hasMorePages = response.hasMorePages;
      _initialLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _initialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreStories() async {
    if (!_hasMorePages || _loading) return;

    _loading = true;
    notifyListeners();

    try {
      final response = await _storyService.fetchStories(_currentPage + 1);
      _stories.addAll(response.stories);
      _hasMorePages = response.hasMorePages;
      _currentPage++;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedStories() async {
    if (_loading) return;
    
    _initialLoadingSaved = true;
    _error = null;
    _savedStoriesPage = 1;
    notifyListeners();

    try {
      final response = await _storyService.fetchSavedStories(_savedStoriesPage);
      _savedStories = response.stories;
      _hasMoreSavedPages = response.hasMorePages;
      _initialLoadingSaved = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _initialLoadingSaved = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSavedStories() async {
    if (!_hasMoreSavedPages || _loading) return;

    _loading = true;
    notifyListeners();

    try {
      final response = await _storyService.fetchSavedStories(_savedStoriesPage + 1);
      _savedStories.addAll(response.stories);
      _hasMoreSavedPages = response.hasMorePages;
      _savedStoriesPage++;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String storyId) async {
    try {
      final success = await _storyService.toggleLike(storyId);
      if (success) {
        // Update like status in stories list
        final storyIndex = _stories.indexWhere((s) => s.id == storyId);
        if (storyIndex != -1) {
          final story = _stories[storyIndex];
          _stories[storyIndex] = Story(
            id: story.id,
            title: story.title,
            content: story.content,
            coverImage: story.coverImage,
            likesCount: story.isLikedByUser ? story.likesCount - 1 : story.likesCount + 1,
            isLikedByUser: !story.isLikedByUser,
            isSaved: story.isSaved,
            createdAt: story.createdAt,
          );
        }

        // Update like status in saved stories list
        final savedStoryIndex = _savedStories.indexWhere((s) => s.id == storyId);
        if (savedStoryIndex != -1) {
          final story = _savedStories[savedStoryIndex];
          _savedStories[savedStoryIndex] = Story(
            id: story.id,
            title: story.title,
            content: story.content,
            coverImage: story.coverImage,
            likesCount: story.isLikedByUser ? story.likesCount - 1 : story.likesCount + 1,
            isLikedByUser: !story.isLikedByUser,
            isSaved: story.isSaved,
            createdAt: story.createdAt,
          );
        }

        // Update like status in latest saved story if it matches
        if (_latestSavedStory?.id == storyId) {
          _latestSavedStory = Story(
            id: _latestSavedStory!.id,
            title: _latestSavedStory!.title,
            content: _latestSavedStory!.content,
            coverImage: _latestSavedStory!.coverImage,
            likesCount: _latestSavedStory!.isLikedByUser 
                ? _latestSavedStory!.likesCount - 1 
                : _latestSavedStory!.likesCount + 1,
            isLikedByUser: !_latestSavedStory!.isLikedByUser,
            isSaved: _latestSavedStory!.isSaved,
            createdAt: _latestSavedStory!.createdAt,
          );
        }
        notifyListeners();
      } else {
        _error = 'Please log in to like stories';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Please log in to like stories';
      notifyListeners();
    }
  }

  Future<void> toggleSave(String storyId) async {
    try {
      final success = await _storyService.toggleSave(storyId);
      if (success) {
        // Update save status in stories list
        final storyIndex = _stories.indexWhere((s) => s.id == storyId);
        if (storyIndex != -1) {
          final story = _stories[storyIndex];
          _stories[storyIndex] = Story(
            id: story.id,
            title: story.title,
            content: story.content,
            coverImage: story.coverImage,
            likesCount: story.likesCount,
            isLikedByUser: story.isLikedByUser,
            isSaved: !story.isSaved,
            createdAt: story.createdAt,
          );
        }

        // Update save status in saved stories list and remove if unsaved
        final savedStoryIndex = _savedStories.indexWhere((s) => s.id == storyId);
        if (savedStoryIndex != -1) {
          _savedStories.removeAt(savedStoryIndex);
        }

        // Update save status in latest saved story if it matches
        if (_latestSavedStory?.id == storyId) {
          _latestSavedStory = Story(
            id: _latestSavedStory!.id,
            title: _latestSavedStory!.title,
            content: _latestSavedStory!.content,
            coverImage: _latestSavedStory!.coverImage,
            likesCount: _latestSavedStory!.likesCount,
            isLikedByUser: _latestSavedStory!.isLikedByUser,
            isSaved: !_latestSavedStory!.isSaved,
            createdAt: _latestSavedStory!.createdAt,
          );
        }
        notifyListeners();
      } else {
        _error = 'Please log in to save stories';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Please log in to save stories';
      notifyListeners();
    }
  }
}
 