import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/story_model.dart';
import '../../../services/api_service.dart';

class StoryResponse {
  final List<Story> stories;
  final bool hasMorePages;

  StoryResponse({required this.stories, required this.hasMorePages});
}

class StoryService {
  ApiService? _apiService;
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.143:8000';

  Future<ApiService> get apiService async {
    if (_apiService == null) {
      final prefs = await SharedPreferences.getInstance();
      _apiService = ApiService(prefs);
    }
    return _apiService!;
  }

  Future<StoryResponse> fetchStories(int page) async {
    try {
      final api = await apiService;
      final response = await api.get(
        '/api/stories?page=$page',
        requiresAuth: false,
      );

      if (response == null) {
        return StoryResponse(stories: [], hasMorePages: false);
      }

      // Handle Laravel pagination structure
      final List<Story> stories = ((response['data'] ?? []) as List)
          .map((storyJson) {
            var story = Story.fromJson(storyJson);
            // Convert relative image path to full URL
            if (story.coverImage.startsWith('/')) {
              story = Story(
                id: story.id,
                title: story.title,
                content: story.content,
                coverImage: _baseUrl + story.coverImage,
                likesCount: story.likesCount,
                isLikedByUser: story.isLikedByUser ?? false,
                isSaved: story.isSaved ?? false,
                createdAt: story.createdAt,
              );
            }
            return story;
          })
          .toList();

      final bool hasMorePages = response['next_page_url'] != null;

      return StoryResponse(stories: stories, hasMorePages: hasMorePages);
    } catch (e) {
      print('Error fetching stories: $e');
      rethrow;
    }
  }

  Future<Story?> fetchLatestSavedStory() async {
    try {
      final api = await apiService;
      final response = await api.get(
        '/api/stories/saved/latest',
        requiresAuth: true,
      );

      if (response == null) return null;

      var story = Story.fromJson(response);
      
      // Convert relative image path to full URL
      if (story.coverImage.startsWith('/')) {
        story = Story(
          id: story.id,
          title: story.title,
          content: story.content,
          coverImage: _baseUrl + story.coverImage,
          likesCount: story.likesCount,
          isLikedByUser: story.isLikedByUser,
          isSaved: story.isSaved,
          createdAt: story.createdAt,
        );
      }

      return story;
    } catch (e) {
      print('Error fetching latest saved story: $e');
      return null;
    }
  }

  Future<bool> toggleLike(String storyId) async {
    try {
      final api = await apiService;
      final response = await api.post(
        '/api/stories/$storyId/like',
        {},
        requiresAuth: true,
      );

      if (response == null) return false;
      return true;
    } catch (e) {
      print('Error toggling story like: $e');
      return false;
    }
  }

  Future<bool> toggleSave(String storyId) async {
    try {
      final api = await apiService;
      final response = await api.post(
        '/api/stories/$storyId/save',
        {},
        requiresAuth: true,
      );

      if (response == null) return false;
      return true;
    } catch (e) {
      print('Error toggling story save: $e');
      return false;
    }
  }

  Future<StoryResponse> fetchSavedStories(int page) async {
    try {
      final api = await apiService;
      final endpoint = Uri(
        path: '/api/stories/saved',
        queryParameters: {'page': page.toString()}
      ).toString();
      
      final response = await api.get(endpoint, requiresAuth: true);
      
      if (response == null) {
        throw Exception('Failed to load saved stories');
      }

      final List<Story> stories = ((response['data'] ?? []) as List)
          .map((storyJson) => Story.fromJson(storyJson))
          .map((story) {
            if (story.coverImage.startsWith('/')) {
              return story.copyWith(
                coverImage: '$_baseUrl${story.coverImage}'
              );
            }
            return story;
          })
          .toList();

      final bool hasMorePages = response['next_page_url'] != null;

      return StoryResponse(stories: stories, hasMorePages: hasMorePages);
    } catch (e) {
      print('Error fetching saved stories: $e');
      rethrow;
    }
  }
}
