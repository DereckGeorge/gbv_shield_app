import 'package:flutter/material.dart';
import '../models/tip.dart';
import '../services/tip_service.dart';
import '../screens/auth/provider/auth_provider.dart';

class TipProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  late final TipService _tipService;
  Tip? _tipOfTheDay;
  bool _isLoading = false;
  String? _error;

  TipProvider(this._authProvider) {
    _tipService = TipService(_authProvider);
  }

  Tip? get tipOfTheDay => _tipOfTheDay;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTipOfTheDay() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tipOfTheDay = await _tipService.getTipOfTheDay();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    if (_tipOfTheDay == null) return;

    try {
      if (_authProvider.token == null) {
        _error = 'Please log in to like tips';
        notifyListeners();
        return;
      }

      final result = await _tipService.toggleLike(_tipOfTheDay!.id);
      await loadTipOfTheDay(); // Reload to get updated like status
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
} 