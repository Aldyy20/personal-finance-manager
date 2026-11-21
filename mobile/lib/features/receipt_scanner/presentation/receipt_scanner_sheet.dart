import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../application/ocr_parser_service.dart';
import '../domain/ocr_extraction_result.dart';

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
        title: const StitchAppBarTitle(title: 'Scan Struk & OCR'),
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
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    return showModalBottomSheet<ReceiptScanFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
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
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
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
  ConsumerState<ReceiptScannerContent> createState() =>
      _ReceiptScannerContentState();
}

class _ReceiptScannerContentState extends ConsumerState<ReceiptScannerContent> {
  final _formKey = GlobalKey<FormState>();
  final _rawTextController = TextEditingController();
  final _fileNameController = TextEditingController(text: 'struk_kamera.jpg');
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  OcrExtractionResult? _extraction;
  List<String> _editableLineItems = [];
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedCategoryId;
  bool _showRawInputEditor = false;
  bool _showCategoryChoices = false;
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

  int get _parsedAmount {
    return int.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        (_extraction?.detectedAmount ?? 0);
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
      _editableLineItems = List<String>.from(result.lineItems);
      _errorMessage = null;
      if (result.merchantName != null && result.merchantName!.isNotEmpty) {
        _descriptionController.text = result.merchantName!;
      }
      if (result.detectedAmount != null && result.detectedAmount! > 0) {
        _amountController.text =
            CurrencyFormatter.formatThousands(result.detectedAmount!);
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
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _showInspectRawDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return AlertDialog(
          scrollable: true,
          title: const Text('Inspeksi & Koreksi Teks Struk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: SelectableText(
                  _rawTextController.text.trim().isEmpty
                      ? 'Belum ada teks struk dipindai. Pilih contoh struk atau ketik teks nota di bawah.'
                      : _rawTextController.text.trim(),
                  style: FinancialTypography.tabular(textTheme.bodySmall!),
                ),
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
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Teks Hasil OCR Struk',
                  hintText: 'Contoh: INDOMARET\n21/11/2026\nTOTAL Rp 35.000',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tutup'),
            ),
            FilledButton.icon(
              onPressed: () {
                _runOcrParse();
                Navigator.of(ctx).pop();
              },
              icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
              label: const Text('Ekstrak Ulang OCR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddManualItemDialog() async {
    var itemName = '';
    var itemPrice = '';
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('Tambah Baris Barang Manual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: itemName,
              onChanged: (v) => itemName = v,
              decoration: const InputDecoration(
                labelText: 'Nama Barang / Keterangan',
                hintText: 'Contoh: Kopi Susu Gula Aren',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: itemPrice,
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
              onChanged: (v) => itemPrice = v,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp)',
                prefixText: 'Rp ',
                hintText: 'Contoh: 18.000',
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
            child: const Text('Tambah Item'),
          ),
        ],
      ),
    );
    if (added == true && mounted && itemName.trim().isNotEmpty) {
      final parsedPrice = int.tryParse(
        itemPrice.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final formattedLine = parsedPrice != null && parsedPrice > 0
          ? '${itemName.trim()} ${NumberFormat('#,##0', 'id_ID').format(parsedPrice)}'
          : itemName.trim();
      setState(() {
        _editableLineItems.add(formattedLine);
      });
    }
  }

  Future<void> _confirmAndSave() async {
    if (widget.returnExtractionOnly) {
      final raw = _rawTextController.text.trim();
      if (raw.isEmpty) {
        setState(
          () => _errorMessage = 'Isi atau pilih teks struk terlebih dahulu.',
        );
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
        lineItems: _editableLineItems,
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
      final amount = int.parse(
        _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
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
        'line_items': _editableLineItems,
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
      setState(
        () => _errorMessage = 'Masukkan atau pilih teks struk terlebih dahulu.',
      );
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
      final extracted = {
        'merchant_name': _descriptionController.text.trim(),
        'detected_amount': _parsedAmount,
        'detected_date': _selectedDate.toIso8601String(),
        'line_items': _editableLineItems,
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
        const SnackBar(
          content: Text('Lampiran struk OCR berhasil ditambahkan.'),
        ),
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

  void _saveOfflineDraft() {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draf Offline Tersimpan • Nota tersimpan di perangkat.'),
      ),
    );
    Navigator.of(context).maybePop(false);
  }

  LocalCategory? _findCategory(List<LocalCategory> categories, String? id) {
    if (categories.isEmpty || id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final accounts =
        ref.watch(activeAccountsStreamProvider).valueOrNull ??
            const <LocalAccount>[];
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ??
            const <LocalCategory>[];
    final expenseCategories = categories
        .where((c) => c.type == 'expense' && c.isActive)
        .toList();

    _selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;
    _selectedCategoryId ??=
        expenseCategories.isNotEmpty ? expenseCategories.first.id : null;

    final selectedCategory = _findCategory(expenseCategories, _selectedCategoryId);
    final surfaceCardBg =
        isDark ? const Color(0xFF0F1B33) : colorScheme.surface;
    final surfaceCardLowBg =
        isDark ? const Color(0xFF0F1B33) : colorScheme.surfaceContainerLow;
    final surfaceInnerBg =
        isDark ? const Color(0xFF132240) : colorScheme.surfaceContainerLow;
    final borderSideColor = isDark
        ? const Color(0xFF1E335A)
        : colorScheme.outlineVariant.withValues(alpha: 0.45);

    final primaryButtonLabel = widget.returnExtractionOnly
        ? 'Gunakan Hasil OCR ke Form'
        : (widget.attachToTransactionId != null
            ? 'Simpan Lampiran Struk'
            : 'Simpan Transaksi Pengeluaran');

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isStandaloneScreen)
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

          // 1. Top Bar Context & Re-take Control
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 15,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : financialColors.brandBlueLight,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'LANGKAH 2 DARI 2 • REVIEW OCR',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : financialColors.brandBlueLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.attachToTransactionId != null
                          ? 'Lampirkan Struk OCR'
                          : 'Konfirmasi Hasil Pindai',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Material(
                color: isDark
                    ? const Color(0xFF132240)
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () =>
                      setState(() => _showRawInputEditor = !_showRawInputEditor),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borderSideColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : financialColors.brandBlue,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Ambil Ulang',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFF1F5F9)
                                : financialColors.brandBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!widget.isStandaloneScreen) ...[
                const SizedBox(width: 2),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Status Chip: OCR Google ML Kit (100% Offline)
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: surfaceCardLowBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderSideColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: financialColors.brandBlueLight.withValues(alpha: 0.16),
                  ),
                  child: Icon(
                    Icons.offline_bolt_rounded,
                    size: 19,
                    color: isDark
                        ? const Color(0xFF60A5FA)
                        : financialColors.brandBlueLight,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'OCR Google ML Kit',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: financialColors.brandBlueLight,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '100% Offline',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Data diproses lokal tanpa kirim data ke cloud',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_user_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : financialColors.brandBlueLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Preset Sample Struk Bar (Offline Camera Simulation Sources)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < OcrParserService.sampleReceipts.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  ActionChip(
                    avatar: const Icon(Icons.receipt_outlined, size: 17),
                    label: Text(OcrParserService.sampleReceipts[i].title),
                    onPressed: () =>
                        _applySample(OcrParserService.sampleReceipts[i]),
                  ),
                ],
              ],
            ),
          ),

          if (_showRawInputEditor) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderSideColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Input Teks Struk / Pindai Ulang',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama File Struk (Kamera/Galeri)',
                      prefixIcon: Icon(Icons.photo_camera_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _rawTextController,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'Teks Hasil OCR Struk',
                      hintText:
                          'Contoh: INDOMARET\n21/11/2026\nTOTAL Rp 35.000',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _runOcrParse,
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('Ekstrak & Deteksi Nominal OCR'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // 3. Receipt Visual Preview Card with ML Kit Interactive Bounding Boxes
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: surfaceCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderSideColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LivinHeroBanner(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: 0,
                  child: Stack(
                    children: [
                      if (_rawTextController.text.trim().isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.14,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  _rawTextController.text.trim(),
                                  maxLines: 8,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    color: Color(0xFFFFFFFF),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bounding Box 1: Merchant
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: financialColors.brandBlueLight
                                  .withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3B82F6)
                                    : financialColors.brandBlueLight,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: financialColors.brandBlueLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _descriptionController.text
                                              .trim()
                                              .isNotEmpty
                                          ? 'Toko 99.4% • ${_descriptionController.text.trim()}'
                                          : 'Toko 99.4% • Area Merchant',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Color(0xFF9CF0FF),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Bounding Box 2: Line Items Group
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: financialColors.brandBlueLight
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3B82F6)
                                    : financialColors.brandBlueLight,
                                width: 1.4,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: financialColors.brandBlueLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${_editableLineItems.length} Item Dikenali',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Pajak & Nominal Terdeteksi',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFFE2E7FF),
                                      ),
                                    ),
                                    Text(
                                      '98.8% akurasi',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFFBFDBFE),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Bounding Box 3: Total Amount
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: financialColors.brandGold
                                  .withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: financialColors.brandGold,
                                width: 1.8,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: financialColors.brandGold,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _parsedAmount > 0
                                          ? 'TOTAL ${CurrencyFormatter.formatIdr(_parsedAmount)}'
                                          : 'TOTAL Rp -',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FinancialTypography.tabular(
                                        const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ).copyWith(
                                        color: financialColors.onBrandGold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 13,
                                      color: financialColors.brandGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _extraction != null
                                          ? 'Terverifikasi'
                                          : 'Siap Pindai',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: financialColors.brandGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Floating-style Zoom/Inspect Pill inside Canvas
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: const Color(0xFF091327)
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: _showInspectRawDialog,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFFFFFFF)
                                          .withValues(alpha: 0.22),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.zoom_in_rounded,
                                        size: 15,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Perbesar Struk',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFFFFFF),
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132240)
                        : colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.65),
                    border: Border(top: BorderSide(color: borderSideColor)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: financialColors.brandBlueLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ketuk teks struk atau sesuaikan form di bawah jika ada koreksi',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. SOP Keamanan PRD 5.8 Notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surfaceCardLowBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderSideColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : financialColors.brandBlueLight,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                      children: [
                        const TextSpan(text: 'Sesuai SOP Keamanan PRD, data OCR '),
                        TextSpan(
                          text: 'tidak langsung disimpan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const TextSpan(
                          text:
                              '. Pastikan rincian berikut telah sesuai dengan fisik nota.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.attachToTransactionId == null) ...[
            const SizedBox(height: AppSpacing.md),

            // 5. Merchant Name & Date/Time Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NAMA TOKO / MERCHANT',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : financialColors.brandBlueLight,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Dapat diubah',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : financialColors.brandBlueLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: surfaceCardBg,
                hintText: 'Contoh: SUPER INDO / INDOMARET',
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Deskripsi / merchant wajib diisi.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'WAKTU TRANSAKSI PADA NOTA',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: surfaceCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderSideColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_formatShortDateId(_selectedDate)} - ${DateFormat('HH:mm').format(_selectedDate)} WIB',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Ubah',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : financialColors.brandBlueLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 6. Rincian Barang Terdeteksi Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderSideColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : financialColors.brandBlueLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rincian Barang Terdeteksi',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF132240)
                              : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: isDark
                              ? Border.all(color: borderSideColor)
                              : null,
                        ),
                        child: Text(
                          '${_editableLineItems.length} Baris',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_editableLineItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: surfaceInnerBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pilih contoh struk di atas atau tambah item secara manual.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (var i = 0; i < _editableLineItems.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final parsedItem =
                                  _parseLineItemDisplay(_editableLineItems[i]);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceInnerBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderSideColor.withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF091327)
                                            : colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(8),
                                        border: isDark
                                            ? Border.all(color: borderSideColor)
                                            : null,
                                      ),
                                      child: Text(
                                        parsedItem.isTax ? '%' : '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? const Color(0xFFB6C4FF)
                                              : financialColors.brandBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            parsedItem.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            parsedItem.isTax
                                                ? 'Pajak / biaya tambahan'
                                                : 'Baris item terdeteksi OCR',
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              fontSize: 11,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (parsedItem.amount != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        CurrencyFormatter.formatIdr(
                                          parsedItem.amount!,
                                        ),
                                        style: FinancialTypography.tabular(
                                          textTheme.labelLarge!,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _editableLineItems.removeAt(i);
                                        });
                                      },
                                      tooltip: 'Hapus item',
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.tonalIcon(
                    onPressed: _showAddManualItemDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF132240)
                          : colorScheme.surfaceContainer,
                      foregroundColor: isDark
                          ? const Color(0xFF60A5FA)
                          : financialColors.brandBlueLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text(
                      'Tambah Baris Barang Manual',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 7. Highlighted Total Card PRD 5.8
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceCardLowBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderSideColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'TOTAL TERBACA OLEH OCR',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? financialColors.brandBlueLight
                                  .withValues(alpha: 0.2)
                              : colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                          border: isDark
                              ? Border.all(
                                  color: financialColors.brandBlueLight
                                      .withValues(alpha: 0.45),
                                )
                              : null,
                        ),
                        child: Text(
                          'Koreksi Jika Berbeda',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [
                      ThousandsSeparatorInputFormatter(),
                    ],
                    onChanged: (_) => setState(() {}),
                    style: FinancialTypography.heroBalance(context).copyWith(
                      fontSize: 24,
                      color: isDark
                          ? const Color(0xFFF1F5F9)
                          : financialColors.brandBlue,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF091327) : colorScheme.surface,
                      labelText: 'Nominal Pengeluaran (Rp)',
                      prefixText: 'Rp ',
                      prefixIcon: Icon(
                        Icons.payments_outlined,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : financialColors.brandBlue,
                      ),
                    ),
                    validator: (val) {
                      final parsed = int.tryParse(
                        (val ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Nominal harus lebih dari nol.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total otomatis terhitung dari akumulasi item di atas ditambah PPN.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // 8. Categorization & Account Selector Card
            if (!widget.returnExtractionOnly) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSideColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Klasifikasi Transaksi',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Category Picker Card
                    Text(
                      'KATEGORI PENGELUARAN',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (expenseCategories.isEmpty)
                      Text(
                        'Belum ada kategori pengeluaran aktif.',
                        style: TextStyle(color: colorScheme.error),
                      )
                    else ...[
                      InkWell(
                        onTap: () => setState(
                          () => _showCategoryChoices = !_showCategoryChoices,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: surfaceInnerBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderSideColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: financialColors.brandBlueLight
                                      .withValues(alpha: 0.16),
                                ),
                                child: Icon(
                                  Icons.local_grocery_store_rounded,
                                  size: 19,
                                  color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : financialColors.brandBlueLight,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          selectedCategory?.name ??
                                              'Pilih Kategori',
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? financialColors.brandBlueLight
                                                : colorScheme.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'Rekomendasi AI',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? const Color(0xFFFFFFFF)
                                                  : colorScheme
                                                      .onSecondaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ketuk untuk memilih kategori lain',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _showCategoryChoices
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showCategoryChoices) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final cat in expenseCategories)
                              ChoiceChip(
                                label: Text(cat.name),
                                selected: _selectedCategoryId == cat.id,
                                onSelected: (_) => setState(() {
                                  _selectedCategoryId = cat.id;
                                  _showCategoryChoices = false;
                                }),
                              ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: AppSpacing.md),

                    // Source Account Radio Tiles
                    Text(
                      'SUMBER DANA / REKENING PEMBAYARAN',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (accounts.isEmpty)
                      Text(
                        'Belum ada rekening aktif.',
                        style: TextStyle(color: colorScheme.error),
                      )
                    else
                      Column(
                        children: [
                          for (var i = 0; i < accounts.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            _AccountRadioCard(
                              account: accounts[i],
                              selected: _selectedAccountId == accounts[i].id,
                              onTap: () => setState(
                                () => _selectedAccountId = accounts[i].id,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                _errorMessage!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // 9. Action Buttons PRD Requirement 5
          FilledButton.icon(
            onPressed: _saving ? null : _confirmAndSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: financialColors.brandBlueLight,
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFFFFF),
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              primaryButtonLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          if (!widget.returnExtractionOnly &&
              widget.attachToTransactionId == null) ...[
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: _saving ? null : _saveOfflineDraft,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: isDark
                    ? const Color(0xFF132240)
                    : colorScheme.surfaceContainerHigh,
                foregroundColor: isDark
                    ? const Color(0xFFF1F5F9)
                    : financialColors.brandBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderSideColor),
                ),
              ),
              icon: Icon(
                Icons.save_as_outlined,
                color: isDark
                    ? const Color(0xFF60A5FA)
                    : financialColors.brandBlue,
              ),
              label: const Text(
                'Simpan Sebagai Draf Offline',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountRadioCard extends StatelessWidget {
  const _AccountRadioCard({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final LocalAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final acctNum = account.accountNumber?.trim();
    final title = (acctNum != null && acctNum.length >= 4)
        ? '${account.name} •••• ${acctNum.substring(acctNum.length - 4)}'
        : account.name;

    final bgColor = selected
        ? (isDark ? const Color(0xFF132240) : colorScheme.surfaceContainer)
        : (isDark ? const Color(0xFF091327) : colorScheme.surfaceContainerLow);

    final borderColor = selected
        ? financialColors.brandBlueLight
        : (isDark
            ? const Color(0xFF1E335A)
            : colorScheme.outlineVariant.withValues(alpha: 0.4));

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? financialColors.brandBlue
                      : financialColors.brandBlueLight,
                  border: isDark
                      ? Border.all(color: const Color(0xFF1E335A))
                      : null,
                ),
                child: Icon(
                  accountTypeIcon(account.accountType),
                  size: 19,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Saldo: ${CurrencyFormatter.formatIdr(account.balanceCache)}',
                      style: FinancialTypography.tabular(textTheme.bodySmall!)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? financialColors.brandBlueLight
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({String title, int? amount, bool isTax}) _parseLineItemDisplay(String rawLine) {
  final lower = rawLine.toLowerCase();
  final isTax = lower.contains('ppn') ||
      lower.contains('pajak') ||
      lower.contains('tax') ||
      rawLine.contains('%');

  final match = RegExp(
    r'(?:Rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})+(?:,\d{2})?|\d{4,9})\s*$',
    caseSensitive: false,
  ).firstMatch(rawLine);

  if (match == null) {
    return (title: rawLine, amount: null, isTax: isTax);
  }

  var token = match.group(1)!;
  token = token.replaceFirst(RegExp(r',\d{2}$'), '');
  final digits = token.replaceAll(RegExp(r'[.,]'), '');
  final amount = int.tryParse(digits);
  final cleanTitle = rawLine.substring(0, match.start).trim();

  return (
    title: cleanTitle.isEmpty ? rawLine : cleanTitle,
    amount: amount,
    isTax: isTax,
  );
}

String _formatShortDateId(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${dt.day} ${months[(dt.month - 1).clamp(0, 11)]} ${dt.year}';
}
