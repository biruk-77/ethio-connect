import 'dart:async';
import 'package:flutter/foundation.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  needsProfileCompletion,
}

class AuthService extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _userId;
  String? _userEmail;
  bool _isLoading = false;

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  final StreamController<AuthStatus> _authStatusController = StreamController<AuthStatus>.broadcast();
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;

  AuthService() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    
    // Simulate checking stored auth token
    await Future.delayed(const Duration(seconds: 2));
    
    // For now, default to unauthenticated
    _updateAuthStatus(AuthStatus.unauthenticated);
    _setLoading(false);
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, accept any email/password
      if (email.isNotEmpty && password.length >= 6) {
        _userId = 'user_123';
        _userEmail = email;
        _updateAuthStatus(AuthStatus.authenticated);
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (email.isNotEmpty && password.length >= 6) {
        _userId = 'user_123';
        _userEmail = email;
        _updateAuthStatus(AuthStatus.needsProfileCompletion);
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    _userId = null;
    _userEmail = null;
    _updateAuthStatus(AuthStatus.unauthenticated);
    _setLoading(false);
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  void _updateAuthStatus(AuthStatus status) {
    _status = status;
    _authStatusController.add(status);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStatusController.close();
    super.dispose();
  }
}
