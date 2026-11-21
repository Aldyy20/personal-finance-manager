import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
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
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
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
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  static const List<({String label, int delta})> _expensePresets = [
    (label: '+50 Rb', delta: 50000),
    (label: '+100 Rb', delta: 100000),
    (label: '+250 Rb', delta: 250000),
    (label: '+500 Rb', delta: 500000),
    (label: '+1 Jt', delta: 1000000),
  ];

  static const List<({String label, int delta})> _incomePresets = [
    (label: '+500 Rb', delta: 500000),
    (label: '+1 Jt', delta: 1000000),
    (label: '+2.5 Jt', delta: 2500000),
    (label: '+5 Jt', delta: 5000000),
    (label: '+10 Jt', delta: 10000000),
  ];

  static const List<({String label, int delta})> _transferPresets = [
    (label: '+100 Rb', delta: 100000),
    (label: '+250 Rb', delta: 250000),
    (label: '+500 Rb', delta: 500000),
    (label: '+1 Jt', delta: 1000000),
  ];

  static final NumberFormat _groupedNumberFormat = NumberFormat('#,##0', 'id_ID');
  static final math.Random _rng = math.Random();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  final _reasonController = TextEditingController();

  late String _type;
  late DateTime _selectedDate;
  late String _refCode;
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
        ? DateTime.fromMillisecondsSinceEpoch(
            existing.transactionDateMs,
            isUtc: true,
          ).toLocal()
        : DateTime.now();
    _refCode = existing != null
        ? 'TX-${existing.id.replaceAll('-', '').toUpperCase().padRight(9, '0').substring(0, 9)}'
        : _generateRefCode();
    _amountController = TextEditingController(
      text: existing != null
          ? CurrencyFormatter.formatThousands(existing.amount)
          : '',
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

  String _generateRefCode() {
    final partA = 1000 + _rng.nextInt(9000);
    final partB = 10000 + _rng.nextInt(90000);
    return 'TX-$partA-$partB';
  }

  int get _parsedAmount {
    return int.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  void _addQuickNominal(int delta) {
    final next = _parsedAmount + delta;
    setState(() {
      _amountController.text = CurrencyFormatter.formatThousands(next);
    });
  }

  void _backspaceNominal() {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      if (digits.length <= 1) {
        _amountController.clear();
      } else {
        final remaining = int.tryParse(digits.substring(0, digits.length - 1));
        if (remaining == null || remaining <= 0) {
          _amountController.clear();
        } else {
          _amountController.text = CurrencyFormatter.formatThousands(remaining);
        }
      }
    });
  }

  void _swapTransferAccounts() {
    if (_sourceAccountId == null && _destinationAccountId == null) return;
    setState(() {
      final previousSource = _sourceAccountId;
      _sourceAccountId = _destinationAccountId;
      _destinationAccountId = previousSource;
      _errorMessage = null;
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _scanReceiptIntoForm() async {
    final res = await ReceiptScannerSheet.extractForForm(context);
    if (res == null || !mounted) return;
    setState(() {
      _pendingOcrReceipt = res;
      if (res.result.merchantName != null &&
          res.result.merchantName!.isNotEmpty) {
        _descriptionController.text = res.result.merchantName!;
      }
      if (res.result.detectedAmount != null && res.result.detectedAmount! > 0) {
        _amountController.text =
            CurrencyFormatter.formatThousands(res.result.detectedAmount!);
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

    final amount = int.parse(
      _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final description = _descriptionController.text.trim();
    final notes = _notesController.text.trim();

    if (_type == 'transfer') {
      if (_sourceAccountId == null || _destinationAccountId == null) {
        setState(
          () => _errorMessage = 'Pilih rekening asal dan rekening tujuan.',
        );
        return;
      }
      if (_sourceAccountId == _destinationAccountId) {
        setState(
          () => _errorMessage = 'Rekening asal dan tujuan harus berbeda.',
        );
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

  LocalAccount? _findAccount(List<LocalAccount> accounts, String? id) {
    if (accounts.isEmpty || id == null) return null;
    for (final acc in accounts) {
      if (acc.id == id) return acc;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTransaction != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final accounts =
        ref.watch(activeAccountsStreamProvider).valueOrNull ?? const <LocalAccount>[];
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];

    final filteredCategories = categories
        .where((c) => c.type == _type && c.isActive)
        .toList();

    if (_type != 'transfer') {
      _accountId ??= accounts.isNotEmpty ? accounts.first.id : null;
      if (_accountId != null && !accounts.any((a) => a.id == _accountId)) {
        _accountId = accounts.isNotEmpty ? accounts.first.id : null;
      }
      if (_categoryId == null ||
          !filteredCategories.any((c) => c.id == _categoryId)) {
        _categoryId =
            filteredCategories.isNotEmpty ? filteredCategories.first.id : null;
      }
    } else {
      _sourceAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;
      if (_destinationAccountId == null && accounts.length > 1) {
        _destinationAccountId =
            accounts.firstWhere((a) => a.id != _sourceAccountId).id;
      }
    }

    final selectedAccount = _findAccount(accounts, _accountId);
    final selectedSource = _findAccount(accounts, _sourceAccountId);
    final selectedDestination = _findAccount(accounts, _destinationAccountId);

    final primaryButtonLabel = isEdit
        ? 'Simpan Revisi (Reversal & Replace)'
        : switch (_type) {
            'income' => 'Simpan Pemasukan',
            'transfer' => 'Konfirmasi & Simpan Transfer',
            _ => 'Simpan Pengeluaran',
          };

    final primaryButtonIcon = isEdit
        ? Icons.history_edu_rounded
        : switch (_type) {
            'income' => Icons.add_circle_outline_rounded,
            'transfer' => Icons.swap_horiz_rounded,
            _ => Icons.task_alt_rounded,
          };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        financialColors.brandBlueLight,
                        financialColors.brandBlue,
                      ],
                    ),
                  ),
                  child: Icon(
                    isEdit
                        ? Icons.edit_note_rounded
                        : Icons.receipt_long_rounded,
                    size: 20,
                    color: financialColors.brandGold,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Transaksi' : 'Catat Transaksi',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        isEdit
                            ? 'Audit revisi aman berbasis jurnal pembalik'
                            : 'Catat arus kas atau mutasi rekening Anda',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 1. Custom 3-in-1 Segmented Tab Switcher
            if (!isEdit) ...[
              _TransactionTypeSwitcher(
                selectedType: _type,
                onChanged: (nextType) {
                  setState(() {
                    _type = nextType;
                    _categoryId = null;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 2. Sapphire Dynamic Hero Amount Card
            _buildHeroAmountCard(context, colorScheme, textTheme, financialColors),
            const SizedBox(height: AppSpacing.md),

            // Nominal input field directly integrated beneath Hero Card
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
              onChanged: (_) => setState(() {}),
              style: FinancialTypography.tabular(textTheme.titleLarge!).copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixText: 'Rp ',
                hintText: 'Contoh: 50.000',
                prefixIcon: Icon(
                  Icons.payments_outlined,
                  color: financialColors.brandBlueLight,
                ),
                suffixIcon: _amountController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Reset nominal',
                        onPressed: () => setState(() => _amountController.clear()),
                        icon: const Icon(Icons.clear_rounded),
                      ),
              ),
              validator: (val) {
                final parsed = int.tryParse(
                  (val ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
                );
                if (parsed == null || parsed <= 0) {
                  return 'Masukkan nominal valid lebih dari nol.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Mode-Specific Account Selector Card
            _buildAccountSection(
              context,
              accounts: accounts,
              selectedAccount: selectedAccount,
              selectedSource: selectedSource,
              selectedDestination: selectedDestination,
            ),
            const SizedBox(height: AppSpacing.md),

            // 4. Category Grid Card (hidden for Transfer)
            if (_type != 'transfer') ...[
              _buildCategoryGridCard(
                context,
                filteredCategories: filteredCategories,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 5. Waktu Transaksi & Metadata Card
            _buildDateAndMetadataCard(context, isEdit: isEdit),

            // 6. Receipt / OCR Attachment Section (Expense New Only)
            if (_type == 'expense' && !isEdit) ...[
              const SizedBox(height: AppSpacing.md),
              _buildReceiptOcrSection(context),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: colorScheme.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // 7. Offline-First Engine Info Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: financialColors.brandBlueLight.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.cloud_sync_outlined,
                      size: 18,
                      color: financialColors.brandBlueLight,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offline-First Engine',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tersimpan instan di SQLite lokal perangkat & otomatis masuk antrean sync cloud saat online.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 8. Primary & Secondary CTAs
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: _type == 'income' && !isEdit
                    ? financialColors.income
                    : financialColors.brandBlueLight,
                foregroundColor: const Color(0xFFFFFFFF),
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
                  : Icon(primaryButtonIcon),
              label: Text(
                primaryButtonLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Batal / Simpan Sebagai Draf'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAmountCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    FinancialColors financialColors,
  ) {
    final (
      badgeLabel,
      badgeIcon,
      rightPillLabel,
      rightPillIcon,
      presets,
    ) = switch (_type) {
      'income' => (
          'NOMINAL PEMASUKAN',
          Icons.stars_rounded,
          'Kredit Buku Besar',
          Icons.trending_up_rounded,
          _incomePresets,
        ),
      'transfer' => (
          'NOMINAL TRANSFER ANTAR REKENING',
          Icons.swap_horizontal_circle_rounded,
          'Enkripsi 256-bit',
          Icons.lock_outline_rounded,
          _transferPresets,
        ),
      _ => (
          'NOMINAL PENGELUARAN',
          Icons.payments_rounded,
          'Koreksi Riil',
          Icons.calculate_outlined,
          _expensePresets,
        ),
    };

    final amountFormatted = _groupedNumberFormat.format(_parsedAmount);
    final terbilang = _terbilangIdr(_parsedAmount);

    return LivinHeroBanner(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: financialColors.brandGold),
                    const SizedBox(width: 6),
                    Text(
                      badgeLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFEFF6FF),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rightPillIcon,
                      size: 13,
                      color: const Color(0xFFBFDBFE),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rightPillLabel,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDBEAFE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Rp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF93C5FD),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amountFormatted,
                        style: FinancialTypography.heroBalance(context).copyWith(
                          color: _parsedAmount > 0
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF93C5FD).withValues(alpha: 0.72),
                          fontSize: 32,
                          height: 1.08,
                        ),
                      ),
                      Container(
                        width: 2.5,
                        height: 26,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: financialColors.brandGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.12),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _backspaceNominal,
                  onLongPress: () => setState(() => _amountController.clear()),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 18,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.volume_up_outlined,
                size: 15,
                color: Color(0xFF93C5FD),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  terbilang,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFDBEAFE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final preset in presets)
                _HeroQuickAmountPill(
                  label: preset.label,
                  onTap: () => _addQuickNominal(preset.delta),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context, {
    required List<LocalAccount> accounts,
    required LocalAccount? selectedAccount,
    required LocalAccount? selectedSource,
    required LocalAccount? selectedDestination,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    if (accounts.isEmpty) {
      return _StitchSectionCard(
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: colorScheme.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Belum ada rekening aktif. Tambah rekening di tab Rekening terlebih dahulu.',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    if (_type == 'transfer') {
      return _StitchSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: financialColors.brandBlueLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: financialColors.brandBlueLight.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: financialColors.brandBlueLight,
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
                          TextSpan(
                            text: 'Net Zero Movement: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: financialColors.brandBlueLight,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'Mutasi antar-rekening pribadi tidak mempengaruhi total arus kas pemasukan atau pengeluaran.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Source Account Card
            Text(
              'DARI REKENING SUMBER',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (selectedSource != null)
              _SelectedAccountCard(
                account: selectedSource,
                trailingLabel: 'Saldo Keluar',
                trailingAmount: _parsedAmount > 0
                    ? '-${CurrencyFormatter.formatIdr(_parsedAmount)}'
                    : CurrencyFormatter.formatIdr(selectedSource.balanceCache),
                trailingColor:
                    _parsedAmount > 0 ? financialColors.expense : null,
              ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final acc in accounts)
                  _AccountChoicePill(
                    icon: accountTypeIcon(acc.accountType),
                    label:
                        '${acc.name} (${CurrencyFormatter.formatIdr(acc.balanceCache)})',
                    selected: _sourceAccountId == acc.id,
                    onTap: () => setState(() {
                      _sourceAccountId = acc.id;
                      if (_destinationAccountId == acc.id &&
                          accounts.length > 1) {
                        _destinationAccountId =
                            accounts.firstWhere((a) => a.id != acc.id).id;
                      }
                    }),
                  ),
              ],
            ),

            // Floating Swap Button Centered
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Divider(color: colorScheme.outlineVariant),
                  Material(
                    color: financialColors.brandBlueLight,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _swapTransferAccounts,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: Color(0xFFFFFFFF),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Destination Account Card
            Text(
              'KE REKENING TUJUAN',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (selectedDestination != null)
              _SelectedAccountCard(
                account: selectedDestination,
                trailingLabel: 'Estimasi Masuk',
                trailingAmount: _parsedAmount > 0
                    ? '+${CurrencyFormatter.formatIdr(_parsedAmount)}'
                    : CurrencyFormatter.formatIdr(selectedDestination.balanceCache),
                trailingColor:
                    _parsedAmount > 0 ? financialColors.income : null,
              ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final acc in accounts)
                  _AccountChoicePill(
                    icon: accountTypeIcon(acc.accountType),
                    label:
                        '${acc.name} (${CurrencyFormatter.formatIdr(acc.balanceCache)})',
                    selected: _destinationAccountId == acc.id,
                    onTap: () => setState(() {
                      _destinationAccountId = acc.id;
                      if (_sourceAccountId == acc.id && accounts.length > 1) {
                        _sourceAccountId =
                            accounts.firstWhere((a) => a.id != acc.id).id;
                      }
                    }),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: financialColors.income.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya Administrasi',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Bebas Biaya (Rp 0)',
                    style: textTheme.labelMedium?.copyWith(
                      color: financialColors.income,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isIncome = _type == 'income';
    final overline = isIncome ? 'DEPOSIT REKENING' : 'SUMBER DANA';
    final sectionTitle = isIncome ? 'Masuk Ke Rekening' : 'Bayar Dari Rekening';
    final projectedBalance = selectedAccount != null
        ? (isIncome
            ? selectedAccount.balanceCache + _parsedAmount
            : selectedAccount.balanceCache - _parsedAmount)
        : 0;

    return _StitchSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            overline,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: financialColors.brandBlueLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sectionTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedAccount != null) ...[
            _SelectedAccountCard(
              account: selectedAccount,
              trailingLabel: isIncome ? 'Estimasi Saldo Baru' : 'Sisa Saldo',
              trailingAmount: CurrencyFormatter.formatIdr(projectedBalance),
              trailingColor: isIncome
                  ? financialColors.income
                  : (projectedBalance < 0
                      ? colorScheme.error
                      : financialColors.brandBlueLight),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isIncome
                      ? Icons.trending_up_rounded
                      : Icons.info_outline_rounded,
                  size: 14,
                  color: isIncome
                      ? financialColors.income
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    isIncome
                        ? 'Saldo rekening bertambah seketika setelah transaksi disimpan.'
                        : 'Saldo rekening terpotong seketika saat pengeluaran dicatat.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final acc in accounts)
                _AccountChoicePill(
                  icon: accountTypeIcon(acc.accountType),
                  label: acc.name,
                  selected: _accountId == acc.id,
                  onTap: () => setState(() => _accountId = acc.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridCard(
    BuildContext context, {
    required List<LocalCategory> filteredCategories,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final isIncome = _type == 'income';

    final rows = <List<LocalCategory>>[];
    for (var i = 0; i < filteredCategories.length; i += 4) {
      rows.add(
        filteredCategories.sublist(
          i,
          math.min(i + 4, filteredCategories.length),
        ),
      );
    }

    return _StitchSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KATEGORI TRANSAKSI',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: financialColors.brandBlueLight,
                      ),
                    ),
                    Text(
                      isIncome ? 'Kategori Pemasukan' : 'Kategori Pengeluaran',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  context.push('/categories');
                },
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Kelola'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (filteredCategories.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Belum ada kategori $_type aktif. Ketuk Kelola untuk membuat kategori.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            )
          else
            Column(
              children: [
                for (var r = 0; r < rows.length; r++) ...[
                  if (r > 0) const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var c = 0; c < 4; c++) ...[
                        if (c > 0) const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: c < rows[r].length
                              ? _CategorySquircleTile(
                                  category: rows[r][c],
                                  selected: _categoryId == rows[r][c].id,
                                  accentColor: isIncome
                                      ? financialColors.income
                                      : financialColors.brandBlueLight,
                                  onTap: () => setState(
                                    () => _categoryId = rows[r][c].id,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDateAndMetadataCard(
    BuildContext context, {
    required bool isEdit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return _StitchSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'DETAIL & WAKTU',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: financialColors.brandBlueLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: financialColors.brandBlueLight.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _shortMonthId(_selectedDate.month),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: financialColors.brandBlueLight,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        _selectedDate.day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Transaksi',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatIndonesianDateTime(_selectedDate),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _pickDate,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Ubah'),
                    ),
                    TextButton(
                      onPressed: _pickTime,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(_selectedDate),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Judul / Keterangan Singkat',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_descriptionController.text.length}/100',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _descriptionController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Contoh: Makan siang / Gaji bulanan',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Catatan Tambahan (Opsional)',
              hintText: _type == 'income'
                  ? 'Pengirim, sumber bonus, atau detail proyek'
                  : 'Detail merchant atau catatan pribadi',
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
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.fingerprint_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ref ID: $_refCode',
                  style: FinancialTypography.tabular(textTheme.bodySmall!).copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isEdit)
                TextButton.icon(
                  onPressed: () => setState(() => _refCode = _generateRefCode()),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Acak Baru', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptOcrSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return _StitchSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'LAMPIRAN BUKTI STRUK',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: financialColors.brandBlueLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: financialColors.brandGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'OCR Google ML Kit',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: financialColors.brandBlueLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_pendingOcrReceipt == null)
            InkWell(
              onTap: _scanReceiptIntoForm,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: financialColors.brandBlueLight.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color:
                        financialColors.brandBlueLight.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: financialColors.brandBlueLight.withValues(
                          alpha: 0.14,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.document_scanner_outlined,
                        color: financialColors.brandBlueLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pindai Struk / Bukti Bayar',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Isi otomatis nominal, tanggal & merchant via OCR',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: financialColors.income.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: financialColors.income.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: financialColors.income,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pendingOcrReceipt!.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Terverifikasi OCR Akurat',
                              style: textTheme.labelSmall?.copyWith(
                                color: financialColors.income,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _scanReceiptIntoForm,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Scan Ulang'),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _pendingOcrReceipt = null),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        label: Text(
                          'Hapus',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TransactionTypeSwitcher extends StatelessWidget {
  const _TransactionTypeSwitcher({
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    const tabs = [
      (
        value: 'expense',
        label: 'Pengeluaran',
        icon: Icons.north_east_rounded,
      ),
      (
        value: 'income',
        label: 'Pemasukan',
        icon: Icons.south_west_rounded,
      ),
      (
        value: 'transfer',
        label: 'Transfer',
        icon: Icons.sync_alt_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(tab.value),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.standardCurve,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selectedType == tab.value
                        ? financialColors.brandBlueLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 15,
                        color: selectedType == tab.value
                            ? const Color(0xFFFFFFFF)
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: selectedType == tab.value
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: selectedType == tab.value
                                ? const Color(0xFFFFFFFF)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StitchSectionCard extends StatelessWidget {
  const _StitchSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: child,
    );
  }
}

class _SelectedAccountCard extends StatelessWidget {
  const _SelectedAccountCard({
    required this.account,
    required this.trailingLabel,
    required this.trailingAmount,
    this.trailingColor,
  });

  final LocalAccount account;
  final String trailingLabel;
  final String trailingAmount;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: financialColors.brandBlueLight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  financialColors.brandBlueLight,
                  financialColors.brandBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              accountTypeIcon(account.accountType),
              color: const Color(0xFFFFFFFF),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: financialColors.brandGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        accountTypeLabel(account.accountType).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: financialColors.brandBlueLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Saldo Aktif: ${CurrencyFormatter.formatIdr(account.balanceCache)}',
                  style: FinancialTypography.tabular(textTheme.bodySmall!).copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailingLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10.5,
                ),
              ),
              Text(
                trailingAmount,
                style: FinancialTypography.tabular(textTheme.titleSmall!).copyWith(
                  fontWeight: FontWeight.w800,
                  color: trailingColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySquircleTile extends StatelessWidget {
  const _CategorySquircleTile({
    required this.category,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final LocalCategory category;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.12)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? accentColor
                : colorScheme.outlineVariant.withValues(alpha: 0.55),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? accentColor : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _categoryIcon(category.name, category.type),
                size: 18,
                color: selected
                    ? const Color(0xFFFFFFFF)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? accentColor : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(String name, String type) {
  final lower = name.toLowerCase();
  if (lower.contains('makan') ||
      lower.contains('minum') ||
      lower.contains('kopi') ||
      lower.contains('food')) {
    return Icons.restaurant_rounded;
  }
  if (lower.contains('transport') ||
      lower.contains('bensin') ||
      lower.contains('ojek') ||
      lower.contains('parkir') ||
      lower.contains('tol')) {
    return Icons.directions_car_rounded;
  }
  if (lower.contains('belanja') ||
      lower.contains('shop') ||
      lower.contains('mart')) {
    return Icons.shopping_bag_rounded;
  }
  if (lower.contains('tagihan') ||
      lower.contains('listrik') ||
      lower.contains('air') ||
      lower.contains('internet') ||
      lower.contains('pulsa')) {
    return Icons.receipt_long_rounded;
  }
  if (lower.contains('kesehatan') ||
      lower.contains('obat') ||
      lower.contains('dokter') ||
      lower.contains('klinik')) {
    return Icons.medical_services_rounded;
  }
  if (lower.contains('pendidikan') ||
      lower.contains('edukasi') ||
      lower.contains('buku') ||
      lower.contains('kursus')) {
    return Icons.school_rounded;
  }
  if (lower.contains('hiburan') ||
      lower.contains('film') ||
      lower.contains('game') ||
      lower.contains('liburan')) {
    return Icons.movie_rounded;
  }
  if (lower.contains('rumah') ||
      lower.contains('sewa') ||
      lower.contains('tempat tinggal') ||
      lower.contains('kost')) {
    return Icons.home_rounded;
  }
  if (lower.contains('gaji') ||
      lower.contains('upah') ||
      lower.contains('salary')) {
    return Icons.work_rounded;
  }
  if (lower.contains('freelance') || lower.contains('proyek')) {
    return Icons.laptop_mac_rounded;
  }
  if (lower.contains('bisnis') ||
      lower.contains('usaha') ||
      lower.contains('penjualan')) {
    return Icons.storefront_rounded;
  }
  if (lower.contains('investasi') ||
      lower.contains('dividen') ||
      lower.contains('saham') ||
      lower.contains('bunga')) {
    return Icons.trending_up_rounded;
  }
  if (lower.contains('hadiah') ||
      lower.contains('bonus') ||
      lower.contains('cashback') ||
      lower.contains('thr')) {
    return Icons.card_giftcard_rounded;
  }
  return type == 'income'
      ? Icons.south_west_rounded
      : Icons.category_rounded;
}

String _shortMonthId(int month) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _formatIndonesianDateTime(DateTime dt) {
  const days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
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
  final dayName = days[dt.weekday - 1];
  final monthName = months[dt.month - 1];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$dayName, ${dt.day} $monthName ${dt.year} • $hh:$mm';
}

String _terbilangIdr(int amount) {
  if (amount <= 0) return 'Nol Rupiah';
  final raw = _terbilangWords(amount).trim();
  if (raw.isEmpty) return 'Nol Rupiah';
  return '${raw[0].toUpperCase()}${raw.substring(1)} Rupiah';
}

String _terbilangWords(int n) {
  const words = [
    '',
    'satu',
    'dua',
    'tiga',
    'empat',
    'lima',
    'enam',
    'tujuh',
    'delapan',
    'sembilan',
    'sepuluh',
    'sebelas',
  ];
  if (n < 12) return words[n];
  if (n < 20) return '${_terbilangWords(n - 10)} belas';
  if (n < 100) {
    return '${_terbilangWords(n ~/ 10)} puluh ${_terbilangWords(n % 10)}'.trim();
  }
  if (n < 200) return 'seratus ${_terbilangWords(n - 100)}'.trim();
  if (n < 1000) {
    return '${_terbilangWords(n ~/ 100)} ratus ${_terbilangWords(n % 100)}'.trim();
  }
  if (n < 2000) return 'seribu ${_terbilangWords(n - 1000)}'.trim();
  if (n < 1000000) {
    return '${_terbilangWords(n ~/ 1000)} ribu ${_terbilangWords(n % 1000)}'.trim();
  }
  if (n < 1000000000) {
    return '${_terbilangWords(n ~/ 1000000)} juta ${_terbilangWords(n % 1000000)}'
        .trim();
  }
  if (n < 1000000000000) {
    return '${_terbilangWords(n ~/ 1000000000)} miliar ${_terbilangWords(n % 1000000000)}'
        .trim();
  }
  return '${_terbilangWords(n ~/ 1000000000000)} triliun ${_terbilangWords(n % 1000000000000)}'
      .trim();
}

class _HeroQuickAmountPill extends StatelessWidget {
  const _HeroQuickAmountPill({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.28),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountChoicePill extends StatelessWidget {
  const _AccountChoicePill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final financialColors = theme.extension<FinancialColors>()!;

    final bgColor = selected
        ? (isDark
            ? const Color(0xFF1E60FF).withValues(alpha: 0.24)
            : colorScheme.secondaryContainer)
        : (isDark ? const Color(0xFF121B2F) : colorScheme.surface);
    final borderColor = selected
        ? financialColors.brandBlueLight
        : colorScheme.outlineVariant.withValues(alpha: 0.65);
    final iconBg = selected
        ? financialColors.brandBlueLight
        : (isDark
            ? const Color(0xFF1E2D4D)
            : colorScheme.surfaceContainerHigh);
    final iconColor = selected
        ? const Color(0xFFFFFFFF)
        : colorScheme.onSurfaceVariant;
    final labelColor = selected
        ? (isDark ? const Color(0xFFDBEAFE) : colorScheme.onSecondaryContainer)
        : colorScheme.onSurface;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : financialColors.brandBlueLight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
