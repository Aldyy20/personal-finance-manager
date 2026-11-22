import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/design_tokens.dart';

/// Opens a modal dialog for securely configuring free Gemini (primary) and
/// Groq (fallback) Vision API keys in device-encrypted storage.
Future<bool> showConfigureAiVisionKeysDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final storage = ref.read(secureStorageServiceProvider);
  final existingGemini = (await storage.getGeminiApiKey()) ?? '';
  final existingGroq = (await storage.getGroqApiKey()) ?? '';

  if (!context.mounted) return false;

  var geminiDraft = existingGemini;
  var groqDraft = existingGroq;
  var obscureGemini = true;
  var obscureGroq = true;

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;
        return AlertDialog(
          scrollable: true,
          title: const Text('Pengaturan AI Vision (Gratis)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Prioritas otomatis: Gemini Flash Lite (Utama) → Groq Qwen 3.8 Vision (Fallback jika limit/gagal) → OCR Offline. Key disimpan terenkripsi hanya di perangkat ini.',
                  style: textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                initialValue: geminiDraft,
                obscureText: obscureGemini,
                onChanged: (v) => geminiDraft = v,
                decoration: InputDecoration(
                  labelText: 'Gemini API Key (Utama)',
                  hintText: 'AIzaSy... (aistudio.google.com)',
                  prefixIcon: const Icon(Icons.auto_awesome_outlined),
                  suffixIcon: IconButton(
                    tooltip: obscureGemini ? 'Tampilkan' : 'Sembunyikan',
                    icon: Icon(
                      obscureGemini
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureGemini = !obscureGemini),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                initialValue: groqDraft,
                obscureText: obscureGroq,
                onChanged: (v) => groqDraft = v,
                decoration: InputDecoration(
                  labelText: 'Groq API Key (Fallback Otomatis)',
                  hintText: 'gsk_... (console.groq.com)',
                  prefixIcon: const Icon(Icons.bolt_rounded),
                  suffixIcon: IconButton(
                    tooltip: obscureGroq ? 'Tampilkan' : 'Sembunyikan',
                    icon: Icon(
                      obscureGroq
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureGroq = !obscureGroq),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kosongkan kolom lalu simpan jika ingin menghapus key atau memakai Server AI/OCR Offline.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Simpan AI Key'),
            ),
          ],
        );
      },
    ),
  );

  if (saved != true) return false;

  await storage.saveAiApiKeys(
    geminiKey: geminiDraft,
    groqKey: groqDraft,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan API Key AI Vision berhasil disimpan.'),
      ),
    );
  }
  return true;
}

