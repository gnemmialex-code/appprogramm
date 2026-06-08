import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _photoPath;
  bool _saving = false;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _anim, curve: const Interval(0, 0.7, curve: Curves.easeOut)));
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _anim, curve: const Interval(0, 0.7, curve: Curves.easeOutCubic)));
    _anim.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  bool get _ok =>
      _nameCtrl.text.trim().isNotEmpty &&
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
          .hasMatch(_emailCtrl.text.trim());

  Future<void> _pickPhoto() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => _PhotoSheet(),
    );
    if (src == null) return;

    final file = await _picker.pickImage(
        source: src, imageQuality: 85, maxWidth: 512, maxHeight: 512);
    if (file == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/profile_photo.jpg';
    await File(file.path).copy(dest);
    setState(() => _photoPath = dest);
  }

  Future<void> _continue() async {
    if (!_ok || _saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final name = _nameCtrl.text.trim();
    await ref.read(userProfileProvider.notifier).update(
          pseudo: name,
          firstName: name,
          email: _emailCtrl.text.trim(),
        );

    final storage = ref.read(appStorageProvider);
    if (_photoPath != null) await storage.saveProfilePhotoPath(_photoPath!);
    await storage.setIntroSeen();

    if (!mounted) return;
    context.go('/onboarding', extra: 'skipProfile');
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1F),
      body: Stack(
        children: [
          // Purple glow top-left
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.brandStart.withValues(alpha: 0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Purple glow bottom-right
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.brandEnd.withValues(alpha: 0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.fromLTRB(28, 16, 28, insets + 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Back
                      GestureDetector(
                        onTap: () => context.go('/intro'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.brandGradient.createShader(b),
                        child: const Text(
                          'Crée ton profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Quelques secondes pour personnaliser\nton espace d\'apprentissage.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Avatar
                      Center(
                        child: _Avatar(
                          photoPath: _photoPath,
                          name: _nameCtrl.text,
                          onTap: _pickPhoto,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Name
                      _Label('Prénom'),
                      const SizedBox(height: 8),
                      _Field(
                        ctrl: _nameCtrl,
                        hint: 'Ton prénom',
                        icon: Icons.person_rounded,
                        type: TextInputType.name,
                        cap: TextCapitalization.words,
                        action: TextInputAction.next,
                        onChange: () => setState(() {}),
                        onDone: () => FocusScope.of(context).nextFocus(),
                      ),
                      const SizedBox(height: 20),
                      // Email
                      _Label('Adresse e-mail'),
                      const SizedBox(height: 8),
                      _Field(
                        ctrl: _emailCtrl,
                        hint: 'prenom@email.com',
                        icon: Icons.mail_rounded,
                        type: TextInputType.emailAddress,
                        action: TextInputAction.done,
                        onChange: () => setState(() {}),
                        onDone: _continue,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'Données stockées localement, jamais partagées.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // CTA
                      AnimatedOpacity(
                        opacity: _ok ? 1.0 : 0.38,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: AppColors.brandGradient,
                                boxShadow: _ok
                                    ? [
                                        BoxShadow(
                                          color: AppColors.brandStart
                                              .withValues(alpha: 0.5),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: InkWell(
                                onTap: _ok ? _continue : null,
                                borderRadius: BorderRadius.circular(20),
                                child: _saving
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Continuer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded,
                                              color: Colors.white, size: 20),
                                        ],
                                      ),
                              ),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoPath;
  final String name;
  final VoidCallback onTap;
  const _Avatar(
      {required this.photoPath, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  photoPath == null ? AppColors.brandGradient : null,
              image: photoPath != null
                  ? DecorationImage(
                      image: FileImage(File(photoPath!)),
                      fit: BoxFit.cover)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandStart.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: photoPath == null
                ? Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C28),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF0D0B1F), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType type;
  final TextCapitalization cap;
  final TextInputAction action;
  final VoidCallback onChange, onDone;

  const _Field({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.type,
    this.cap = TextCapitalization.none,
    required this.action,
    required this.onChange,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      textCapitalization: cap,
      textInputAction: action,
      onChanged: (_) => onChange(),
      onSubmitted: (_) => onDone(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon,
            color: Colors.white.withValues(alpha: 0.4), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              const BorderSide(color: AppColors.brandStart, width: 2),
        ),
      ),
    );
  }
}

class _PhotoSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SheetTile(
            icon: Icons.photo_library_rounded,
            label: 'Bibliothèque photos',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 10),
          _SheetTile(
            icon: Icons.camera_alt_rounded,
            label: 'Prendre une photo',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.brandStart, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
