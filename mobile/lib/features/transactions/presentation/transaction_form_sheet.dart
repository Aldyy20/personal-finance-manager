import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../receipt_scanner/presentation/receipt_scanner_sheet.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    super.key,
    this.initialType = 'expense',
    this.existingTransaction,
    this.initialAccountId,
    this.initialDestinationAccountId,
    this.initialCategoryId,
  });

  final String initialType;
  final LocalTransaction? existingTransaction;
  final String? initialAccountId;
  final String? initialDestinationAccountId;
  final String? initialCategoryId;

  static Future<bool?> show(
    BuildContext context, {
    String initialType = 'expense',
    LocalTransaction? existingTransaction,
    String? initialAccountId,
    String? initialDestinationAccountId,
    String? initialCategoryId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: TransactionFormSheet(
          initialType: existingTransaction?.type ?? initialType,
          existingTransaction: existingTransaction,
          initialAccountId: initialAccountId,
          initialDestinationAccountId: initialDestinationAccountId,
          initialCategoryId: initialCategoryId,
        ),
      ),
    );
  }

  @override
  ConsumerState<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  final _reasonController = TextEditingController();

  late String _type;
  late DateTime _selectedDate;
  String? _accountId;
  String? _sourceAccountId;
  String? _destinationAccountId;
  String? _categoryId;
  ReceiptScanFormResult? _pendingOcrReceipt;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _type = existing?.type ?? widget.initialType;
    _selectedDate = existing != null
        ? DateTime.fromMillisecondsSinceEpoch(existing.transactionDateMs, isUtc: true).toLocal()
        : DateTime.now();
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _notesController = TextEditingController(
      text: existing?.notes ?? '',
    );
    _accountId = widget.initialAccountId;
    _sourceAccountId = widget.initialAccountId;
    _destinationAccountId = widget.initialDestinationAccountId;
    _categoryId = existing?.categoryId ?? widget.initialCategoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
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

  Future<void> _scanReceiptIntoForm() async {
    final res = await ReceiptScannerSheet.extractForForm(context);
    if (res == null || !mounted) return;
    setState(() {
      _pendingOcrReceipt = res;
      if (res.result.merchantName != null && res.result.merchantName!.isNotEmpty) {
        _descriptionController.text = res.result.merchantName!;
      }
      if (res.result.detectedAmount != null && res.result.detectedAmount! > 0) {
        _amountController.text = res.result.detectedAmount!.toString();
      }
      if (res.result.detectedDate != null) {
        _selectedDate = res.result.detectedDate!;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final amount = int.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final description = _descriptionController.text.trim();
    final notes = _notesController.text.trim();

    if (_type == 'transfer') {
      if (_sourceAccountId == null || _destinationAccountId == null) {
        setState(() => _errorMessage = 'Pilih rekening asal dan rekening tujuan.');
        return;
      }
      if (_sourceAccountId == _destinationAccountId) {
        setState(() => _errorMessage = 'Rekening asal dan tujuan harus berbeda.');
        return;
      }
    } else {
      if (_accountId == null) {
        setState(() => _errorMessage = 'Pilih rekening transaksi.');
        return;
      }
      if (_categoryId == null) {
        setState(() => _errorMessage = 'Pilih kategori transaksi.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      final existing = widget.existingTransaction;

      if (existing == null) {
        if (_type == 'transfer') {
          await txRepo.createTransfer(
            userId: session.userId,
            deviceId: session.deviceId,
            sourceAccountId: _sourceAccountId!,
            destinationAccountId: _destinationAccountId!,
            amount: amount,
            transactionDate: _selectedDate,
            description: description.isEmpty ? null : description,
            notes: notes.isEmpty ? null : notes,
          );
        } else {
          final created = await txRepo.createIncomeOrExpense(
            userId: session.userId,
            deviceId: session.deviceId,
            type: _type,
            accountId: _accountId!,
            categoryId: _categoryId!,
            amount: amount,
            transactionDate: _selectedDate,
            description: description.isEmpty ? null : description,
            notes: notes.isEmpty ? null : notes,
          );

          if (_pendingOcrReceipt != null) {
            final ocr = _pendingOcrReceipt!;
            await ref.read(receiptRepositoryProvider).saveReceiptWithOcr(
                  userId: session.userId,
                  deviceId: session.deviceId,
                  transactionId: created.id,
                  filePath: 'local_receipts/${ocr.fileName}',
                  localFilePath: 'local_receipts/${ocr.fileName}',
                  fileName: ocr.fileName,
                  mimeType: 'image/jpeg',
                  fileSize: utf8.encode(ocr.rawText).length,
                  ocrText: ocr.rawText,
                  extractedData: ocr.result.toJson(),
                );
          }
        }
      } else {
        final reason = _reasonController.text.trim();
        if (existing.type == 'transfer') {
          await txRepo.updateTransfer(
            userId: session.userId,
            deviceId: session.deviceId,
            transactionId: existing.id,
            sourceAccountId: _sourceAccountId,
            destinationAccountId: _destinationAccountId,
            amount: amount,
            transactionDate: _selectedDate,
            description: description.isEmpty ? null : description,
            notes: notes.isEmpty ? null : notes,
            reason: reason.isEmpty ? null : reason,
          );
        } else {
          await txRepo.updateIncomeOrExpense(
            userId: session.userId,
            deviceId: session.deviceId,
            transactionId: existing.id,
            type: _type,
            accountId: _accountId,
            categoryId: _categoryId,
            amount: amount,
            transactionDate: _selectedDate,
            description: description.isEmpty ? null : description,
            notes: notes.isEmpty ? null : notes,
            reason: reason.isEmpty ? null : reason,
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Transaksi ${CurrencyFormatter.formatIdr(amount)} berhasil dicatat.'
                : 'Revisi transaksi ${CurrencyFormatter.formatIdr(amount)} berhasil disimpan.',
          ),
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTransaction != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accounts = ref.watch(activeAccountsStreamProvider).valueOrNull ?? const <LocalAccount>[];
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];

    final filteredCategories = categories
        .where((c) => c.type == _type && c.isActive)
        .toList();

    if (_type != 'transfer') {
      _accountId ??= accounts.isNotEmpty ? accounts.first.id : null;
      if (_categoryId == null || !filteredCategories.any((c) => c.id == _categoryId)) {
        _categoryId = filteredCategories.isNotEmpty ? filteredCategories.first.id : null;
      }
    } else {
      _sourceAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;
      if (_destinationAccountId == null && accounts.length > 1) {
        _destinationAccountId = accounts.firstWhere((a) => a.id != _sourceAccountId).id;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Transaksi' : 'Catat Transaksi',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!isEdit) ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Keluar'),
                    icon: Icon(Icons.north_east),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Masuk'),
                    icon: Icon(Icons.south_west),
                  ),
                  ButtonSegment(
                    value: 'transfer',
                    label: Text('Transfer'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                    _categoryId = null;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_type == 'expense' && !isEdit) ...[
              OutlinedButton.icon(
                onPressed: _scanReceiptIntoForm,
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(
                  _pendingOcrReceipt == null
                      ? 'Isi Otomatis dari Scan Struk (OCR)'
                      : 'Struk Siap Dilampirkan (${_pendingOcrReceipt!.fileName})',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: FinancialTypography.tabular(textTheme.headlineSmall!),
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixText: 'Rp ',
                hintText: 'Contoh: 50000',
              ),
              validator: (val) {
                final parsed = int.tryParse((val ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                if (parsed == null || parsed <= 0) {
                  return 'Masukkan nominal valid lebih dari nol.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_type == 'transfer') ...[
              Text('Rekening Asal', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final acc in accounts)
                    ChoiceChip(
                      label: Text('${acc.name} (${CurrencyFormatter.formatIdr(acc.balanceCache)})'),
                      selected: _sourceAccountId == acc.id,
                      onSelected: (_) => setState(() => _sourceAccountId = acc.id),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Rekening Tujuan', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final acc in accounts)
                    ChoiceChip(
                      label: Text('${acc.name} (${CurrencyFormatter.formatIdr(acc.balanceCache)})'),
                      selected: _destinationAccountId == acc.id,
                      onSelected: (_) => setState(() => _destinationAccountId = acc.id),
                    ),
                ],
              ),
            ] else ...[
              Text('Rekening', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              if (accounts.isEmpty)
                Text(
                  'Belum ada rekening aktif.',
                  style: TextStyle(color: colorScheme.error),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final acc in accounts)
                      ChoiceChip(
                        label: Text(acc.name),
                        selected: _accountId == acc.id,
                        onSelected: (_) => setState(() => _accountId = acc.id),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _type == 'income' ? 'Kategori Pemasukan' : 'Kategori Pengeluaran',
                style: textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (filteredCategories.isEmpty)
                Text(
                  'Belum ada kategori $_type aktif.',
                  style: TextStyle(color: colorScheme.error),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final cat in filteredCategories)
                      ChoiceChip(
                        label: Text(cat.name),
                        selected: _categoryId == cat.id,
                        onSelected: (_) => setState(() => _categoryId = cat.id),
                      ),
                  ],
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Contoh: Makan siang / Gaji bulanan',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan Tambahan (Opsional)',
              ),
            ),
            if (isEdit) ...[
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Perubahan (Audit Revisi)',
                  hintText: 'Contoh: Koreksi nominal sesuai struk',
                ),
              ),
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
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isEdit ? 'Simpan Revisi (Reversal & Replace)' : 'Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}

