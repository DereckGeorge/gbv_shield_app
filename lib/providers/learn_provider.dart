import 'package:flutter/material.dart';
import '../models/learn.dart';
import '../models/learn_category.dart';
import '../services/learn_service.dart';
import '../screens/auth/provider/auth_provider.dart';

class LearnProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final LearnService _service;
  
  List<LearnCategory> _categories = [];
  List<Learn> _learns = [];
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  LearnProvider(this._authProvider)
      : _service = LearnService(token: _authProvider.token);

  List<LearnCategory> get categories => _categories;
  List<Learn> get learns => _learns;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadCategories() async {
    try {
      _categories = await _service.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadLearns({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    if (!_hasMore && !refresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.getLearns(
        categoryId: _selectedCategoryId,
        page: _currentPage,
      );

      if (refresh) {
        _learns = result['data'];
      } else {
        _learns.addAll(result['data']);
      }

      _currentPage = result['current_page'];
      _lastPage = result['last_page'];
      _hasMore = _currentPage < _lastPage;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    _currentPage = 1;
    _hasMore = true;
    _learns = [];
    _selectedCategoryId = categoryId;
    notifyListeners();
    loadLearns(refresh: true);
  }

  Future<void> toggleLike(String learnId) async {
    try {
      if (!_authProvider.isLoggedIn) {
        throw Exception('Please log in to like content');
      }

      await _service.toggleLike(learnId);
      
      final index = _learns.indexWhere((l) => l.id == learnId);
      if (index != -1) {
        final learn = _learns[index];
        _learns[index] = Learn(
          id: learn.id,
          categoryId: learn.categoryId,
          title: learn.title,
          content: learn.content,
          youtubeUrl: learn.youtubeUrl,
          imagePath: learn.imagePath,
          likesCount: learn.isLiked ? learn.likesCount - 1 : learn.likesCount + 1,
          isLiked: !learn.isLiked,
          isRead: learn.isRead,
          createdAt: learn.createdAt,
          updatedAt: learn.updatedAt,
          category: learn.category,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsRead(String learnId) async {
    try {
      if (!_authProvider.isLoggedIn) {
        throw Exception('Please log in to mark content as read');
      }

      await _service.markAsRead(learnId);
      
      final index = _learns.indexWhere((l) => l.id == learnId);
      if (index != -1) {
        final learn = _learns[index];
        _learns[index] = Learn(
          id: learn.id,
          categoryId: learn.categoryId,
          title: learn.title,
          content: learn.content,
          youtubeUrl: learn.youtubeUrl,
          imagePath: learn.imagePath,
          likesCount: learn.likesCount,
          isLiked: learn.isLiked,
          isRead: true,
          createdAt: learn.createdAt,
          updatedAt: learn.updatedAt,
          category: learn.category,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
} 