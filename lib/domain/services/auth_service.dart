import 'package:dart_lesson/domain/data_providers/session_data_provider.dart';

class AuthService {
  Future<bool> isAuth() async {
    final sessionDataProvider = SessionDataProvider();
    final sessionId = await sessionDataProvider.getSessionId();
    final isAuth = sessionId != null;
    return isAuth;
  }
}
