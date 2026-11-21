import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../domain/ocr_extraction_result.dart';
import '../application/ocr_parser_service.dart';

class ReceiptScanFormResult {
  const ReceiptScanFormResult({
    required this.result,
    required this.rawText,
    required this.fileName,
  });

  final OcrExtractionResult result;
  final String rawText;
  final String fileName;
}

class ReceiptScannerScreen extends StatelessWidget {
  const ReceiptScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Struk & OCR'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: ReceiptScannerContent(isStandaloneScreen: true),
        ),
      ),
    );
  }
}

class ReceiptScannerSheet {
  const ReceiptScannerSheet._();

  static Future<ReceiptScanFormResult?> extractForForm(BuildContext context) {
    return showModalBottomSheet<ReceiptScanFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: ReceiptScannerContent(
            isStandaloneScreen: false,
            returnExtractionOnly: true,
          ),
        ),
      ),
    );
  }

  static Future<bool?> showSaveOrAttach(
    BuildContext context, {
    String? attachToTransactionId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ReceiptScannerContent(
            isStandaloneScreen: false,
            returnExtractionOnly: false,
            attachToTransactionId: attachToTransactionId,
          ),
        ),
      ),
    );
  }
}

class ReceiptScannerContent extends ConsumerStatefulWidget {
  const ReceiptScannerContent({
    super.key,
    required this.isStandaloneScreen,
    this.returnExtractionOnly = false,
    this.attachToTransactionId,
  });

  final bool isStandaloneScreen;
  final bool returnExtractionOnly;
  final String? attachToTransactionId;

  @override
  ConsumerState<ReceiptScannerContent> createState() => _ReceiptScannerContentState();
}

class _ReceiptScannerContentState extends ConsumerState<ReceiptScannerContent> {
  final _formKey = GlobalKey<FormState>();
  final _rawTextController = TextEditingController();
  final _fileNameController = TextEditingController(text: 'struk_kamera.jpg');
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  OcrExtractionResult? _extraction;
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedCategoryId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _rawTextController.dispose();
    _fileNameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _applySample(({String title, String fileName, String rawText}) sample) {
    _fileNameController.text = sample.fileName;
    _rawTextController.text = sample.rawText;
    _runOcrParse();
  }

  void _runOcrParse() {
    final parser = ref.read(ocrParserServiceProvider);
    final result = parser.parseReceiptText(_rawTextController.text);
    setState(() {
      _extraction = result;
      _errorMessage = null;
      if (result.merchantName != null && result.merchantName!.isNotEmpty) {
        _descriptionController.text = result.merchantName!;
      }
      if (result.detectedAmount != null && result.detectedAmount! > 0) {
        _amountController.text = result.detectedAmount!.toString();
      }
      if (result.detectedDate != null) {
        _selectedDate = result.detectedDate!;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _confirmAndSave() async {
    if (widget.returnExtractionOnly) {
      final raw = _rawTextController.text.trim();
      if (raw.isEmpty) {
        setState(() => _errorMessage = 'Isi atau pilih teks struk terlebih dahulu.');
        return;
      }
      final parsedAmount = int.tryParse(
        _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final parsed = OcrExtractionResult(
        rawText: raw,
        merchantName: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : _extraction?.merchantName,
        detectedAmount: parsedAmount ?? _extraction?.detectedAmount,
        detectedDate: _selectedDate,
        lineItems: _extraction?.lineItems ?? const [],
      );
      Navigator.of(context).pop(
        ReceiptScanFormResult(
          result: parsed,
          rawText: raw,
          fileName: _fileNameController.text.trim().isEmpty
              ? 'struk_ocr.jpg'
              : _fileNameController.text.trim(),
        ),
      );
      return;
    }

    if (widget.attachToTransactionId != null) {
      await _attachToExistingTransaction();
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      setState(() => _errorMessage = 'Pilih rekening dan kategori pengeluaran.');
      return;
    }

    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final amount = int.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final txRepo = ref.read(transactionRepositoryProvider);
      final receiptRepo = ref.read(receiptRepositoryProvider);
      final fileName = _fileNameController.text.trim().isEmpty
          ? 'struk_ocr.jpg'
          : _fileNameController.text.trim();

      final tx = await txRepo.createIncomeOrExpense(
        userId: session.userId,
        deviceId: session.deviceId,
        type: 'expense',
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        amount: amount,
        transactionDate: _selectedDate,
        description: _descriptionController.text.trim(),
        notes: 'Dicatat via Scan Struk OCR ($fileName)',
      );

      final extracted = {
        'merchant_name': _descriptionController.text.trim(),
        'detected_amount': amount,
        'detected_date': _selectedDate.toIso8601String(),
        'line_items': _extraction?.lineItems ?? const [],
      };
      final rawText = _rawTextController.text.trim();

      await receiptRepo.saveReceiptWithOcr(
        userId: session.userId,
        deviceId: session.deviceId,
        transactionId: tx.id,
        filePath: 'local_receipts/$fileName',
        localFilePath: 'local_receipts/$fileName',
        fileName: fileName,
        mimeType: 'image/jpeg',
        fileSize: utf8.encode(rawText).length,
        ocrText: rawText,
        extractedData: extracted,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengeluaran ${CurrencyFormatter.formatIdr(amount)} & lampiran struk disimpan offline.',
          ),
        ),
      );
      if (widget.isStandaloneScreen) {
        Navigator.of(context).maybePop(true);
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _attachToExistingTransaction() async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;
    final rawText = _rawTextController.text.trim();
    if (rawText.isEmpty) {
      setState(() => _errorMessage = 'Masukkan atau pilih teks struk terlebih dahulu.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final receiptRepo = ref.read(receiptRepositoryProvider);
      final fileName = _fileNameController.text.trim().isEmpty
          ? 'struk_ocr.jpg'
          : _fileNameController.text.trim();
      final extracted = _extraction?.toJson() ??
          {
            'merchant_name': _descriptionController.text.trim(),
            'detected_date': _selectedDate.toIso8601String(),
          };

      await receiptRepo.saveReceiptWithOcr(
        userId: session.userId,
        deviceId: session.deviceId,
        transactionId: widget.attachToTransactionId!,
        filePath: 'local_receipts/$fileName',
        localFilePath: 'local_receipts/$fileName',
        fileName: fileName,
        mimeType: 'image/jpeg',
        fileSize: utf8.encode(rawText).length,
        ocrText: rawText,
        extractedData: extracted,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lampiran struk OCR berhasil ditambahkan.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accounts = ref.watch(activeAccountsStreamProvider).valueOrNull ?? const <LocalAccount>[];
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];
    final expenseCategories = categories
        .where((c) => c.type == 'expense' && c.isActive)
        .toList();

    _selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;
    _selectedCategoryId ??= expenseCategories.isNotEmpty ? expenseCategories.first.id : null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner_outlined, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.attachToTransactionId != null
                      ? 'Lampirkan Struk OCR'
                      : 'Pemindai Struk & Ekstraksi OCR',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (!widget.isStandaloneScreen)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ambil contoh struk kamera/galeri atau tempel hasil OCR untuk diperiksa sebelum disimpan.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final sample in OcrParserService.sampleReceipts)
                ActionChip(
                  avatar: const Icon(Icons.receipt_outlined, size: 18),
                  label: Text(sample.title),
                  onPressed: () => _applySample(sample),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'Nama File Struk (Kamera/Galeri)',
              prefixIcon: Icon(Icons.photo_camera_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _rawTextController,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Teks Hasil OCR Struk',
              hintText: 'Contoh: INDOMARET\n21/11/2026\nTOTAL Rp 35.000',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _runOcrParse,
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: const Text('Ekstrak & Deteksi Nominal OCR'),
          ),
          if (_extraction != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Terdeteksi OCR',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Merchant: ${_extraction!.merchantName ?? '-'}'),
                  Text(
                    'Total: ${_extraction!.detectedAmount != null ? CurrencyFormatter.formatIdr(_extraction!.detectedAmount!) : 'Tidak terdeteksi'}',
                    style: FinancialTypography.tabular(textTheme.bodyMedium!),
                  ),
                  if (_extraction!.lineItems.isNotEmpty)
                    Text('Item terdeteksi: ${_extraction!.lineItems.length} baris'),
                ],
              ),
            ),
          ],
          if (widget.attachToTransactionId == null) ...[
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(
              title: 'Konfirmasi Data Transaksi',
              subtitle: 'Silakan koreksi hasil ekstraksi sebelum konfirmasi simpan',
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Merchant / Deskripsi Pengeluaran',
                prefixIcon: Icon(Icons.store_outlined),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Deskripsi / merchant wajib diisi.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: FinancialTypography.tabular(textTheme.titleMedium!),
              decoration: const InputDecoration(
                labelText: 'Nominal Pengeluaran (Rp)',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (val) {
                final parsed = int.tryParse((val ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                if (parsed == null || parsed <= 0) {
                  return 'Nominal harus lebih dari nol.';
                }
                return null;
              },
            ),
            if (!widget.returnExtractionOnly) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Rekening Sumber', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              if (accounts.isEmpty)
                const Text('Belum ada rekening aktif.')
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final acc in accounts)
                      ChoiceChip(
                        label: Text(acc.name),
                        selected: _selectedAccountId == acc.id,
                        onSelected: (_) => setState(() => _selectedAccountId = acc.id),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Text('Kategori Pengeluaran', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              if (expenseCategories.isEmpty)
                const Text('Belum ada kategori pengeluaran aktif.')
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final cat in expenseCategories)
                      ChoiceChip(
                        label: Text(cat.name),
                        selected: _selectedCategoryId == cat.id,
                        onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                      ),
                  ],
                ),
            ],
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _saving ? null : _confirmAndSave,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              widget.returnExtractionOnly
                  ? 'Gunakan Hasil OCR ke Form'
                  : (widget.attachToTransactionId != null
                      ? 'Simpan Lampiran Struk'
                      : 'Konfirmasi & Simpan Transaksi + Struk'),
            ),
          ),
        ],
      ),
    );
  }
}

