import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/note_model.dart';
import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';

/// A reusable "Note" button that opens an editor sheet bound to [location].
///
/// Two visual variants:
///  • [onDark] = true  → translucent white pill (for coloured step cards)
///  • [onDark] = false → soft tinted card (for light sheet cards)
class NoteButton extends ConsumerWidget {
  final NoteLocation location;
  final bool onDark;
  const NoteButton({super.key, required this.location, this.onDark = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existing = ref
        .watch(notesProvider.notifier)
        .noteForLocation(location);
    // We watch notesProvider so the button rebuilds when the note changes.
    ref.watch(notesProvider);
    final hasNote = existing != null;

    final fg = onDark ? Colors.white : AppColors.lavender;
    final bg = onDark
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.lavender.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: () => openNoteEditor(context, ref, location),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onDark
                ? Colors.white.withValues(alpha: 0.28)
                : AppColors.lavender.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasNote ? Icons.sticky_note_2_rounded : Icons.note_add_rounded,
              size: 20,
              color: fg,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasNote ? 'Ma note' : 'Ajouter une note',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                  if (hasNote) ...[
                    const SizedBox(height: 2),
                    Text(
                      existing.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              hasNote ? Icons.edit_rounded : Icons.add_rounded,
              size: 16,
              color: onDark ? Colors.white70 : AppColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the bottom-sheet editor for the note at [location].
void openNoteEditor(
  BuildContext context,
  WidgetRef ref,
  NoteLocation location,
) {
  final existing = ref.read(notesProvider.notifier).noteForLocation(location);
  final controller = TextEditingController(text: existing?.content ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 18,
        bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.lavender,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ma note',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.displayPath.replaceAll('\n', ' '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 6,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Note, réflexion, idée à retenir, question à creuser…',
              hintStyle: TextStyle(color: AppColors.inkSoft),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (existing != null)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ref.read(notesProvider.notifier).deleteNote(existing.id);
                      Navigator.pop(sheetCtx);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Supprimer'),
                  ),
                ),
              if (existing != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandStart,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(notesProvider.notifier)
                        .saveNote(location, controller.text);
                    Navigator.pop(sheetCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          controller.text.trim().isEmpty
                              ? 'Note vide — non enregistrée'
                              : 'Note enregistrée ✓',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Retrouve toutes tes notes dans Profil → Mes notes',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.inkSoft.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
