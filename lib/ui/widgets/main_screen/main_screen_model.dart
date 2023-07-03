import 'package:dart_lesson/domain/services/auth_service.dart';
import 'package:dart_lesson/ui/navigation/main_navigation.dart';
import 'package:flutter/material.dart';

class MainScreenModel extends ChangeNotifier {
  final _authService = AuthService();

  Future<void> logout(BuildContext context) async {
    _authService.logout();
    MainNavigation.resetNavigation(context);
    notifyListeners();
  }
}
