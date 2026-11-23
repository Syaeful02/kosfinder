import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/providers/auth_provider.dart';
import 'package:kostfinder/repositories/auth_repository.dart';

final testUser = User(
  id: 'user-uuid-1',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  email: 'owner@example.com',
  createdAt: '2026-11-23T10:00:00.000Z',
);

class FakeAuthRepository extends AuthRepository {
  User? user;
  Object? errorToThrow;
  int signUpCallCount = 0;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  FakeAuthRepository({this.user, this.errorToThrow});

  @override
  User? get currentUser => user;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    signUpCallCount++;
    if (errorToThrow != null) throw errorToThrow!;
    user = testUser;
    return AuthResponse(user: user);
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    if (errorToThrow != null) throw errorToThrow!;
    user = testUser;
    return AuthResponse(user: user);
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    if (errorToThrow != null) throw errorToThrow!;
    user = null;
  }
}

void main() {
  group('AuthProvider', () {
    test('initializes with the repository session', () {
      final repository = FakeAuthRepository(user: testUser);
      final provider = AuthProvider(repository: repository);

      expect(provider.currentUser?.id, 'user-uuid-1');
      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('signUp updates session and notifies listeners', () async {
      final repository = FakeAuthRepository();
      final provider = AuthProvider(repository: repository);
      var notificationCount = 0;
      provider.addListener(() => notificationCount++);

      final success = await provider.signUp(
        email: 'owner@example.com',
        password: 'secure1',
      );

      expect(success, isTrue);
      expect(repository.signUpCallCount, 1);
      expect(provider.currentUser?.email, 'owner@example.com');
      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
      expect(notificationCount, 2);
    });

    test('signInWithPassword sets the user and clears loading state', () async {
      final repository = FakeAuthRepository();
      final provider = AuthProvider(repository: repository);

      final success = await provider.signInWithPassword(
        email: 'owner@example.com',
        password: 'secure1',
      );

      expect(success, isTrue);
      expect(repository.signInCallCount, 1);
      expect(provider.currentUser?.id, 'user-uuid-1');
      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('signOut clears the session', () async {
      final repository = FakeAuthRepository(user: testUser);
      final provider = AuthProvider(repository: repository);

      final success = await provider.signOut();

      expect(success, isTrue);
      expect(repository.signOutCallCount, 1);
      expect(provider.currentUser, isNull);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('auth failures are exposed in provider state', () async {
      final repository = FakeAuthRepository(
        errorToThrow: const AuthException('Invalid credentials'),
      );
      final provider = AuthProvider(repository: repository);

      final success = await provider.signInWithPassword(
        email: 'owner@example.com',
        password: 'wrong-password',
      );

      expect(success, isFalse);
      expect(provider.errorMessage, contains('Invalid credentials'));
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
    });
  });
}
