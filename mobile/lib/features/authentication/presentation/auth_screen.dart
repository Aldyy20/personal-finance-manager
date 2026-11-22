import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/widgets/finance_widgets.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  int _modeIndex = 0; // 0: Masuk, 1: Daftar, 2: Lupa Sandi
  int _forgotStep = 0; // 0: Email, 1: Verifikasi OTP, 2: Sandi Baru
  bool _submitting = false;
  bool _sendingOtp = false;
  bool _registerOtpSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _otpCooldownSeconds = 0;
  Timer? _cooldownTimer;
  String? _errorMessage;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _otpCooldownSeconds = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_otpCooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _otpCooldownSeconds = 0);
      } else {
        setState(() => _otpCooldownSeconds--);
      }
    });
  }

  String? _validateEmail(String? val) {
    final trimmed = val?.trim() ?? '';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (trimmed.isEmpty || !emailRegex.hasMatch(trimmed)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  String? _validateOtp(String? val) {
    final trimmed = val?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return 'Masukkan 6 digit kode OTP dari email Anda.';
    }
    return null;
  }

  void _switchMode(int nextMode) {
    _cooldownTimer?.cancel();
    setState(() {
      _modeIndex = nextMode;
      _otpCooldownSeconds = 0;
      _errorMessage = null;
      if (nextMode != 2) {
        _forgotStep = 0;
      }
      _otpController.clear();
    });
  }

  Future<void> _sendRegisterOtp() async {
    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _errorMessage = emailError);
      return;
    }

    setState(() {
      _sendingOtp = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final meta =
          await ref.read(authRepositoryProvider).sendRegisterOtp(email: email);
      if (!mounted) return;
      setState(() => _registerOtpSent = true);
      _startCooldown(meta.resendCooldownSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP 6 digit telah dikirim ke $email.'),
        ),
      );
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.displayMessage);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _resendForgotOtp() async {
    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _errorMessage = emailError);
      return;
    }

    setState(() {
      _sendingOtp = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final meta = await ref
          .read(authRepositoryProvider)
          .sendPasswordResetOtp(email: email);
      if (!mounted) return;
      _startCooldown(meta.resendCooldownSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP baru telah dikirim ke $email.'),
        ),
      );
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.displayMessage);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final controller = ref.read(activeSessionProvider.notifier);
      final authRepo = ref.read(authRepositoryProvider);

      if (_modeIndex == 0) {
        await controller.login(
          email: email,
          password: _passwordController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil masuk dan menyinkronkan data.'),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
        return;
      }

      if (_modeIndex == 1) {
        await controller.register(
          email: email,
          password: _passwordController.text,
          passwordConfirmation: _confirmController.text,
          otpCode: _otpController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat dan terhubung ke cloud.'),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
        return;
      }

      // _modeIndex == 2 (Lupa Kata Sandi 3-Langkah)
      if (_forgotStep == 0) {
        final meta = await authRepo.sendPasswordResetOtp(email: email);
        if (!mounted) return;
        setState(() {
          _forgotStep = 1;
          _otpController.clear();
        });
        _startCooldown(meta.resendCooldownSeconds);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode OTP telah dikirim ke $email.'),
          ),
        );
      } else if (_forgotStep == 1) {
        await authRepo.verifyPasswordResetOtp(
          email: email,
          otpCode: _otpController.text.trim(),
        );
        if (!mounted) return;
        setState(() => _forgotStep = 2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP terverifikasi. Buat kata sandi baru Anda.'),
          ),
        );
      } else {
        await authRepo.resetPasswordWithOtp(
          email: email,
          otpCode: _otpController.text.trim(),
          password: _newPasswordController.text,
          passwordConfirmation: _confirmNewPasswordController.text,
        );
        if (!mounted) return;
        _cooldownTimer?.cancel();
        _passwordController.clear();
        _confirmController.clear();
        _otpController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
        setState(() {
          _otpCooldownSeconds = 0;
          _forgotStep = 0;
          _modeIndex = 0;
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kata sandi berhasil diperbarui. Silakan masuk dengan kata sandi baru.',
            ),
          ),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.displayMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildForgotStepper(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final financialColors = theme.extension<FinancialColors>()!;

    const steps = ['1. Email', '2. Kode OTP', '3. Sandi Baru'];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: i == _forgotStep
                      ? financialColors.brandBlueLight
                      : (i < _forgotStep
                          ? financialColors.income.withValues(alpha: 0.16)
                          : colorScheme.surfaceContainerLow),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: i == _forgotStep
                        ? financialColors.brandBlueLight
                        : (i < _forgotStep
                            ? financialColors.income.withValues(alpha: 0.45)
                            : colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (i < _forgotStep) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: financialColors.income,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        steps[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: i == _forgotStep
                              ? const Color(0xFFFFFFFF)
                              : (i < _forgotStep
                                  ? financialColors.income
                                  : colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final primaryButtonLabel = switch (_modeIndex) {
      0 => 'Masuk',
      1 => 'Daftar Akun',
      _ => switch (_forgotStep) {
          0 => 'Kirim Kode OTP',
          1 => 'Verifikasi Kode OTP',
          _ => 'Simpan Kata Sandi Baru',
        },
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun & Sinkronisasi Cloud'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LivinHeroBanner(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const AppLogoBadge(size: 48, borderRadius: 14),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'Personal Finance Manager',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Masuk atau daftar untuk mencadangkan catatan keuangan Anda ke cloud dan sinkronisasi lintas perangkat.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFFFFFFF).withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Masuk')),
                        ButtonSegment(value: 1, label: Text('Daftar')),
                        ButtonSegment(value: 2, label: Text('Lupa Sandi')),
                      ],
                      selected: {_modeIndex},
                      onSelectionChanged: (sel) => _switchMode(sel.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (_modeIndex == 2) _buildForgotStepper(context),

                    // Email field (Masuk, Daftar, and Lupa Sandi Step 0)
                    if (_modeIndex != 2 || _forgotStep == 0) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (_modeIndex == 1 && _registerOtpSent) {
                            setState(() => _registerOtpSent = false);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: _validateEmail,
                      ),
                    ],

                    // Password & Confirmation (Masuk & Daftar)
                    if (_modeIndex == 0 || _modeIndex == 1) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: 'Tampilkan/Sembunyikan',
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 8) {
                            return 'Kata sandi minimal 8 karakter.';
                          }
                          return null;
                        },
                      ),
                    ],

                    if (_modeIndex == 0) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _switchMode(2),
                          child: const Text('Lupa kata sandi?'),
                        ),
                      ),
                    ],

                    if (_modeIndex == 1) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            tooltip: 'Tampilkan/Sembunyikan',
                            onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return 'Konfirmasi kata sandi tidak cocok.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Kode OTP Email (6 digit)',
                                hintText: '123456',
                                prefixIcon: Icon(Icons.mark_email_read_outlined),
                                counterText: '',
                              ),
                              validator: _validateOtp,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: FilledButton.tonal(
                              onPressed: (_sendingOtp || _otpCooldownSeconds > 0)
                                  ? null
                                  : _sendRegisterOtp,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(116, 48),
                              ),
                              child: _sendingOtp
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _otpCooldownSeconds > 0
                                          ? 'Kirim (${_otpCooldownSeconds}d)'
                                          : (_registerOtpSent
                                              ? 'Kirim Ulang'
                                              : 'Kirim OTP'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      if (_registerOtpSent) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: financialColors.income.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: financialColors.income.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                                color: financialColors.income,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Kode OTP terkirim ke ${_emailController.text.trim()}. Periksa kotak masuk atau folder spam.',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // Lupa Sandi Step 1: Verifikasi Kode OTP
                    if (_modeIndex == 2 && _forgotStep == 1) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email Tujuan OTP',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _emailController.text.trim(),
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _submitting
                                  ? null
                                  : () => setState(() {
                                        _forgotStep = 0;
                                        _otpController.clear();
                                        _errorMessage = null;
                                      }),
                              child: const Text('Ubah Email'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Kode OTP Email (6 digit)',
                          hintText: 'Masukkan 6 digit OTP',
                          prefixIcon: Icon(Icons.mark_email_read_outlined),
                          counterText: '',
                        ),
                        validator: _validateOtp,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: (_sendingOtp || _otpCooldownSeconds > 0)
                              ? null
                              : _resendForgotOtp,
                          child: Text(
                            _otpCooldownSeconds > 0
                                ? 'Kirim Ulang OTP (${_otpCooldownSeconds}d)'
                                : 'Kirim Ulang OTP',
                          ),
                        ),
                      ),
                    ],

                    // Lupa Sandi Step 2: Kata Sandi Baru
                    if (_modeIndex == 2 && _forgotStep == 2) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: financialColors.income.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: financialColors.income.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 18,
                              color: financialColors.income,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'OTP terverifikasi untuk ${_emailController.text.trim()}.',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: 'Tampilkan/Sembunyikan',
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 8) {
                            return 'Kata sandi baru minimal 8 karakter.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _confirmNewPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            tooltip: 'Tampilkan/Sembunyikan',
                            onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val != _newPasswordController.text) {
                            return 'Konfirmasi kata sandi baru tidak cocok.';
                          }
                          return null;
                        },
                      ),
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
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(primaryButtonLabel),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Lanjutkan Tanpa Akun'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
