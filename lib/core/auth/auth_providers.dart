import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The shared Supabase client (initialised in `main()`).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Emits an [AuthState] on every sign-in / sign-out / token refresh. The router
/// listens to this to gate the whole app behind authentication.
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseClientProvider).auth.onAuthStateChange,
);

/// Convenience accessor for the current user without subscribing.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(supabaseClientProvider).auth.currentUser,
);

/// Thin wrapper around Supabase auth exposing the operations the UI needs:
/// sign in / sign up with email + password, sign out, password reset, and
/// account deletion (via a server-side SQL function — see setup notes).
class AuthController {
  AuthController(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

  /// Creates a new account. Returns `true` when the project requires e-mail
  /// confirmation (no active session yet), so the UI can tell the user to check
  /// their inbox instead of pretending they're already logged in.
  Future<bool> signUp(String email, String password) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
    return res.session == null;
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email.trim());

  /// Permanently deletes the signed-in account. Supabase doesn't allow a client
  /// to delete its own auth user directly, so this calls the `delete_user`
  /// Postgres function (SECURITY DEFINER) and then signs out locally.
  Future<void> deleteAccount() async {
    await _client.rpc('delete_user');
    await _client.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref.watch(supabaseClientProvider)),
);

/// Maps a Supabase error to a short, user-facing French message.
String authErrorMessage(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'E-mail ou mot de passe incorrect.';
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already')) {
      return 'Un compte existe déjà avec cet e-mail.';
    }
    if (msg.contains('at least 6') || msg.contains('password should')) {
      return 'Mot de passe trop faible (6 caractères minimum).';
    }
    if (msg.contains('not confirmed') || msg.contains('email not confirmed')) {
      return 'Confirme ton e-mail avant de te connecter.';
    }
    if (msg.contains('invalid email') ||
        msg.contains('unable to validate email')) {
      return 'Adresse e-mail invalide.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Trop de tentatives. Réessaie plus tard.';
    }
    return error.message;
  }
  return 'Une erreur est survenue. Vérifie ta connexion.';
}
