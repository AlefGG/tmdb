// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_lesson/domain/api_client/account_api_client.dart';
import 'package:dart_lesson/domain/api_client/api_client_exception.dart';
import 'package:dart_lesson/domain/api_client/auth_api_client.dart';
import 'package:dart_lesson/domain/data_providers/session_data_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String login;
  final String password;
  AuthLoginEvent({
    required this.login,
    required this.password,
  });
}

enum AuthStateStatus { authorized, notAuthorized, inProgress }

abstract class AuthState {}

class AuthUnauthorizedState extends AuthState {}

class AuthAuthorizedState extends AuthState {}

class AuthFailureState extends AuthState {
  final Object error;

  AuthFailureState(this.error);
}

class AuthInProgressState extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();
  final _authApiClient = AuthApiClient();
  AuthBloc(AuthState initialState) : super(initialState) {
    on<AuthCheckStatusEvent>((event, emit) async {
      final sessionId = await _sessionDataProvider.getSessionId();
      final newState =
          sessionId != null ? AuthAuthorizedState() : AuthUnauthorizedState();
      emit(newState);
    });
    on<AuthLoginEvent>((event, emit) async {
      try {
        final sessionId = await _authApiClient.auth(
          username: event.login,
          password: event.password,
        );
        final accountId = await _accountApiClient.getAccountInfo(sessionId);
        await _sessionDataProvider.setSessionId(sessionId);
        await _sessionDataProvider.setAccountId(accountId);
        emit(AuthAuthorizedState());
      } catch (e) {
        emit(AuthFailureState(e));
      }
    });
    on<AuthLogoutEvent>((event, emit) async {
      try {
        await _sessionDataProvider.deleteSessionId();
        await _sessionDataProvider.deleteAccoutId();
        emit(AuthAuthorizedState());
      } catch (e) {
        emit(AuthFailureState(e));
      }
    });
    add(AuthCheckStatusEvent());
  }
}

class AuthService {
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();
  final _authApiClient = AuthApiClient();

  Future<bool> isAuth() async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final isAuth = sessionId != null;
    return isAuth;
  }

  Future<void> login(String login, String password) async {
    final sessionId = await _authApiClient.auth(
      username: login,
      password: password,
    );
    final accountId = await _accountApiClient.getAccountInfo(sessionId);
    await _sessionDataProvider.setSessionId(sessionId);
    await _sessionDataProvider.setAccountId(accountId);
  }

  Future<void> logout() async {
    await _sessionDataProvider.deleteSessionId();
    await _sessionDataProvider.deleteAccoutId();
  }
}
