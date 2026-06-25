import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../ui/theme/app_colors.dart';

/// Single screen handling both **sign in** (existing accounts) and **sign up**
/// (new accounts), toggled by a tab at the top. Also offers a "forgot password"
/// reset flow. Once authentication succeeds the router redirects automatically.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSignUp = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final auth = ref.read(authControllerProvider);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    try {
      if (_isSignUp) {
        final needsConfirmation = await auth.signUp(email, password);
        if (needsConfirmation) {
          // E-mail confirmation is enabled on the project: no session yet.
          if (!mounted) return;
          _showMessage(
            'Compte créé ! Confirme ton e-mail puis connecte-toi.',
          );
          setState(() => _isSignUp = false);
          return;
        }
        // Otherwise a session was created → the auth gate redirects us in.
      } else {
        await auth.signIn(email, password);
      }
      // Success → router's auth gate redirects us into the app.
    } catch (e) {
      if (!mounted) return;
      _showError(authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _emailCtrl.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Réinitialiser le mot de passe',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'On t\'envoie un lien de réinitialisation par e-mail.',
              style: TextStyle(color: AppColors.inkSoft, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: _fieldDecoration('Ton e-mail'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler', style: TextStyle(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'Envoyer',
              style: TextStyle(
                color: AppColors.brandStart,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;
    try {
      await ref.read(authControllerProvider).sendPasswordReset(email);
      if (!mounted) return;
      _showMessage('E-mail de réinitialisation envoyé à $email');
    } catch (e) {
      if (!mounted) return;
      _showError(authErrorMessage(e));
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  void _showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static InputDecoration _fieldDecoration(String hint, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brandStart, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand mark
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandStart.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isSignUp ? 'Créer un compte' : 'Bon retour 👋',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp
                        ? 'Inscris-toi pour commencer ton apprentissage.'
                        : 'Connecte-toi pour retrouver ta progression.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSoft,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Mode switch
                  _ModeToggle(
                    isSignUp: _isSignUp,
                    onChanged: (v) {
                      if (_loading) return;
                      setState(() => _isSignUp = v);
                    },
                  ),
                  const SizedBox(height: 22),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: _fieldDecoration('Adresse e-mail'),
                    validator: (v) {
                      final val = v?.trim() ?? '';
                      if (val.isEmpty) return 'Entre ton e-mail.';
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'E-mail invalide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: _isSignUp
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) {
                      if (!_isSignUp) _submit();
                    },
                    decoration: _fieldDecoration(
                      'Mot de passe',
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.inkSoft,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if ((v ?? '').isEmpty) return 'Entre ton mot de passe.';
                      if (_isSignUp && (v?.length ?? 0) < 6) {
                        return '6 caractères minimum.';
                      }
                      return null;
                    },
                  ),

                  // Confirm password (sign up only)
                  if (_isSignUp) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _fieldDecoration('Confirmer le mot de passe'),
                      validator: (v) {
                        if (!_isSignUp) return null;
                        if (v != _passwordCtrl.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                    ),
                  ],

                  // Forgot password (sign in only)
                  if (!_isSignUp) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading ? null : _forgotPassword,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: AppColors.brandStart,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Submit
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandStart,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Créer mon compte' : 'Se connecter',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Toggle hint
                  Center(
                    child: GestureDetector(
                      onTap: _loading
                          ? null
                          : () => setState(() => _isSignUp = !_isSignUp),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.inkSoft,
                          ),
                          children: [
                            TextSpan(
                              text: _isSignUp
                                  ? 'Déjà un compte ? '
                                  : 'Pas encore de compte ? ',
                            ),
                            TextSpan(
                              text: _isSignUp ? 'Se connecter' : 'S\'inscrire',
                              style: const TextStyle(
                                color: AppColors.brandStart,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control switching between "Connexion" and "Inscription".
class _ModeToggle extends StatelessWidget {
  final bool isSignUp;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.isSignUp, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _segment('Connexion', !isSignUp, () => onChanged(false)),
          _segment('Inscription', isSignUp, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: active ? AppColors.brandGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
