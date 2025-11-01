import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<bool> register(
    String fullName,
    String phoneNumber,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService().register(
      fullName,
      phoneNumber,
      email,
      password,
    );

    if (result != null) {
      _user = UserModel.fromJson(result['user']);
    }

    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService().login(phoneNumber, password);

    if (result != null) {
      _user = UserModel.fromJson(result['user']);
    }

    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<void> logout() async {
    await AuthService().logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await AuthService().getToken();
    if (token == null) {
      _user = null;
      notifyListeners();
    }
  }
}
