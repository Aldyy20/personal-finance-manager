import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/currency_formatter.dart';

class AccountFormSheet extends ConsumerStatefulWidget {
  const AccountFormSheet({
    super.key,
    this.existingAccount,
  });

  final LocalAccount? existingAccount;

  static Future<bool?> show(
    BuildContext context, {
    LocalAccount? existingAccount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: AccountFormSheet(existingAccount: existingAccount),
      ),
    );
  }

  @override
  ConsumerState<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _institutionController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _openingBalanceController;
  late String _accountType;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final acc = widget.existingAccount;
    _accountType = acc?.accountType ?? 'bank';
    _nameController = TextEditingController(text: acc?.name ?? '');
    _institutionController = TextEditingController(text: acc?.institutionName ?? '');
    _accountNumberController = TextEditingController(text: acc?.accountNumber ?? '');
    _openingBalanceController = TextEditingController(
      text: acc != null ? CurrencyFormatter.formatThousands(acc.openingBalance) : '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _accountNumberController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final accountRepo = ref.read(accountRepositoryProvider);
      final institution = _institutionController.text.trim();
      final accNum = _accountNumberController.text.trim();

      if (widget.existingAccount == null) {
        final opening = int.tryParse(
              _openingBalanceController.text.replaceAll(RegExp(r'[^0-9-]'), ''),
            ) ??
            0;
        await accountRepo.createAccount(
          userId: session.userId,
          deviceId: session.deviceId,
          name: _nameController.text.trim(),
          accountType: _accountType,
          institutionName: institution.isEmpty ? null : institution,
          accountNumber: accNum.isEmpty ? null : accNum,
          openingBalance: opening,
        );
      } else {
        await accountRepo.updateAccount(
          userId: session.userId,
          deviceId: session.deviceId,
          accountId: widget.existingAccount!.id,
          name: _nameController.text.trim(),
          accountType: _accountType,
          institutionName: institution.isEmpty ? null : institution,
          accountNumber: accNum.isEmpty ? null : accNum,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingAccount == null
                ? 'Rekening berhasil ditambahkan.'
                : 'Data rekening berhasil diperbarui.',
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
    final isEdit = widget.existingAccount != null;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                    isEdit ? 'Edit Rekening' : 'Tambah Rekening Baru',
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
            Text('Tipe Rekening', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'cash', label: Text('Tunai')),
                ButtonSegment(value: 'bank', label: Text('Bank')),
                ButtonSegment(value: 'e_wallet', label: Text('E-Wallet')),
                ButtonSegment(value: 'other', label: Text('Lain')),
              ],
              selected: {_accountType},
              onSelectionChanged: (sel) => setState(() => _accountType = sel.first),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Rekening',
                hintText: 'Contoh: BCA Utama / GoPay',
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Nama rekening wajib diisi.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Nama Bank / Penyedia (Opsional)',
                hintText: 'Contoh: Bank Central Asia',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening / Akun (Opsional)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _openingBalanceController,
              enabled: !isEdit,
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
              style: FinancialTypography.tabular(textTheme.titleMedium!),
              decoration: InputDecoration(
                labelText: 'Saldo Awal (Rp)',
                prefixText: 'Rp ',
                helperText: isEdit
                    ? 'Saldo awal tidak dapat diubah langsung. Gunakan Koreksi Saldo (Adjustment).'
                    : 'Dicatat sebagai opening movement pada ledger.',
              ),
            ),
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
              label: Text(isEdit ? 'Simpan Perubahan' : 'Buat Rekening'),
            ),
          ],
        ),
      ),
    );
  }
}

