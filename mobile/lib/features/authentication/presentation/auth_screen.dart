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
  const AuthScreen({
    super.key,
    this.isAppLockMode = false,
  });

  final bool isAppLockMode;

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
  final _forgotOtpFocusNode = FocusNode();

  int _modeIndex = 0; // 0: Masuk, 1: Daftar, 2: Lupa Sandi
  int _forgotStep = 0; // 0: Email, 1: Kode OTP, 2: Sandi Baru
  bool _submitting = false;
  bool _sendingOtp = false;
  bool _registerOtpSent = false;
  bool _rememberMe = true;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _otpCooldownSeconds = 0;
  Timer? _cooldownTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final currentSession = ref.read(activeSessionProvider).valueOrNull;
    if (currentSession != null && currentSession.isCloudAuthenticated) {
      _emailController.text = currentSession.email;
    }
    _forgotOtpFocusNode.addListener(_onOtpFocusOrTextChanged);
    _otpController.addListener(_onOtpFocusOrTextChanged);
    _loadSavedEmailAndPreference();
  }

  void _onOtpFocusOrTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSavedEmailAndPreference() async {
    final storage = ref.read(secureStorageServiceProvider);
    final savedEmail = await storage.getLastEmail();
    final remember = await storage.isRememberEmailEnabled();
    if (!mounted) return;
    setState(() {
      if (_emailController.text.trim().isEmpty &&
          savedEmail != null &&
          savedEmail.trim().isNotEmpty) {
        _emailController.text = savedEmail.trim();
      }
      _rememberMe = remember;
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _forgotOtpFocusNode.removeListener(_onOtpFocusOrTextChanged);
    _forgotOtpFocusNode.dispose();
    _otpController.removeListener(_onOtpFocusOrTextChanged);
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

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool _isEmailValid(String value) => _emailRegex.hasMatch(value.trim());

  String? _validateEmail(String? val) {
    if (!_isEmailValid(val ?? '')) {
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

  Future<void> _handleBiometricPressed({
    required bool canUseBiometric,
    required bool isCloudSession,
    required bool biometricEnabled,
  }) async {
    if (!canUseBiometric) {
      setState(() {
        _errorMessage = isCloudSession && !biometricEnabled
            ? 'Fitur sidik jari belum diaktifkan. Masuk dengan kata sandi lalu aktifkan Login Cepat di menu Pengaturan.'
            : 'Untuk keamanan, masuk pertama kali wajib menggunakan email dan kata sandi. Aktifkan Login Sidik Jari di menu Pengaturan setelah masuk.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final ok =
          await ref.read(activeSessionProvider.notifier).unlockWithBiometric();
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _errorMessage =
              'Verifikasi sidik jari dibatalkan atau gagal. Silakan coba lagi atau gunakan kata sandi.';
        });
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

  Future<void> _confirmSwitchAccountLogout() async {
    final sessionEmail = ref.read(activeSessionProvider).valueOrNull?.email ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Keluar & Ganti Akun'),
        content: Text(
          sessionEmail.isNotEmpty
              ? 'Keluar dari sesi akun $sessionEmail pada perangkat ini?'
              : 'Keluar dari sesi akun ini pada perangkat ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    _passwordController.clear();
    await ref.read(activeSessionProvider.notifier).logout();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_modeIndex == 1 && !_acceptedTerms) {
      setState(() {
        _errorMessage = 'Harap setujui Syarat & Ketentuan terlebih dahulu.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final controller = ref.read(activeSessionProvider.notifier);
      final authRepo = ref.read(authRepositoryProvider);

      if (_modeIndex == 0) {
        if (widget.isAppLockMode) {
          await controller.unlockWithPassword(
            email: email,
            password: _passwordController.text,
            rememberEmail: _rememberMe,
          );
        } else {
          await controller.login(
            email: email,
            password: _passwordController.text,
            rememberEmail: _rememberMe,
          );
        }
        if (!mounted) return;
        if (widget.isAppLockMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aplikasi berhasil dibuka.'),
            ),
          );
          return;
        }
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
        if (widget.isAppLockMode) return;
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

  @override
  Widget build(BuildContext context) {
    final palette = _AuthPalette.of(context);
    final session = ref.watch(activeSessionProvider).valueOrNull;
    final biometricEnabled =
        ref.watch(biometricEnabledProvider).valueOrNull ?? false;
    final isCloudSession = session?.isCloudAuthenticated ?? false;
    final canUseBiometric =
        widget.isAppLockMode && isCloudSession && biometricEnabled;

    return Scaffold(
      backgroundColor: palette.canvasBg,
      body: Stack(
        children: [
          _AmbientBackdrop(palette: palette),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Form(
                    key: _formKey,
                    child: switch (_modeIndex) {
                      0 => _buildLoginContent(
                          context,
                          palette,
                          isCloudSession: isCloudSession,
                          biometricEnabled: biometricEnabled,
                          canUseBiometric: canUseBiometric,
                        ),
                      1 => _buildRegisterContent(context, palette),
                      _ => _buildForgotPasswordContent(context, palette),
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginContent(
    BuildContext context,
    _AuthPalette palette, {
    required bool isCloudSession,
    required bool biometricEnabled,
    required bool canUseBiometric,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top navigation / lock status bar
        Row(
          children: [
            if (!widget.isAppLockMode)
              IconButton(
                tooltip: 'Kembali',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: Icon(Icons.arrow_back_rounded, color: palette.heading),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.pillBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: palette.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Akses Terkunci',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.heading,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: palette.pillBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: palette.gold,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Enkripsi Aman',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Centered Stitch Hero Branding
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        palette.primaryGradientStart.withValues(alpha: 0.35),
                        palette.accent.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                  child: const AppLogoBadge(size: 64, borderRadius: 17),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: palette.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.canvasBg, width: 2),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 12,
                      color: palette.onGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: palette.pillBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'PERSONAL FINANCE MANAGER',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.pillText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Selamat Datang Kembali',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: palette.heading,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isAppLockMode
                  ? (canUseBiometric
                      ? 'Masukkan kata sandi akun Anda atau gunakan sidik jari untuk membuka aplikasi.'
                      : 'Masukkan kata sandi akun Anda untuk membuka aplikasi.')
                  : 'Masuk untuk mengelola aset, rekening, dan sinkronisasi catatan keuangan Anda dengan aman.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Elevated Stitch Login Form Card
        _StitchCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Email Terdaftar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: palette.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: palette.inputFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, size: 12, color: palette.accent),
                        const SizedBox(width: 4),
                        Text(
                          'Private Vault',
                          style: textTheme.labelSmall?.copyWith(
                            color: palette.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('auth_email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  filled: true,
                  fillColor: palette.inputFill,
                  prefixIcon: Icon(
                    Icons.alternate_email_rounded,
                    color: palette.accent,
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Password Akun',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: palette.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kata Sandi',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('auth_password_field'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  hintText: 'Masukkan kata sandi',
                  filled: true,
                  fillColor: palette.inputFill,
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: palette.accent,
                  ),
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
              const SizedBox(height: AppSpacing.sm),

              // Remember device & Forgot password row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (val) =>
                                    setState(() => _rememberMe = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Ingat Saya di Perangkat Ini',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: palette.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitting ? null : () => _switchMode(2),
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: palette.linkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _ErrorBanner(message: _errorMessage!),
              ],

              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: palette.primaryCta,
                  foregroundColor: const Color(0xFFFFFFFF),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFFFFFF),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Masuk Sekarang',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: Divider(color: palette.cardBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'atau',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.muted,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: palette.cardBorder)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const Key('biometric_login_button'),
                onPressed: _submitting
                    ? null
                    : () => _handleBiometricPressed(
                          canUseBiometric: canUseBiometric,
                          isCloudSession: isCloudSession,
                          biometricEnabled: biometricEnabled,
                        ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: canUseBiometric
                      ? palette.biometricActiveBg
                      : palette.inputFill.withValues(alpha: 0.65),
                  foregroundColor:
                      canUseBiometric ? palette.accent : palette.muted,
                  side: BorderSide(
                    color: canUseBiometric
                        ? palette.accent.withValues(alpha: 0.5)
                        : palette.cardBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(
                  Icons.fingerprint_rounded,
                  size: 22,
                  color: canUseBiometric ? palette.accent : palette.muted,
                ),
                label: const Text(
                  'Masuk Cepat dengan Sidik Jari',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Trust & Sync Info Cards
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.infoCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.pillBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 20,
                  color: palette.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terenkripsi & Aman',
                      style: textTheme.titleSmall?.copyWith(
                        color: palette.heading,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Data keuangan Anda dilindungi enkripsi aman dan privasi terjaga sepanjang waktu.',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: palette.infoStripBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 18,
                color: palette.gold,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sinkronisasi otomatis menjaga catatan tetap aman lintas perangkat.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Footer CTA
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              'Belum punya akun?',
              style: textTheme.bodyMedium?.copyWith(color: palette.muted),
            ),
            TextButton(
              onPressed: _submitting ? null : () => _switchMode(1),
              child: Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  color: palette.linkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (widget.isAppLockMode) ...[
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: _submitting ? null : _confirmSwitchAccountLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Keluar & Ganti Akun'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterContent(BuildContext context, _AuthPalette palette) {
    final textTheme = Theme.of(context).textTheme;
    final passwordsMatch = _confirmController.text.isNotEmpty &&
        _confirmController.text == _passwordController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Stack Header Bar
        Row(
          children: [
            IconButton(
              tooltip: 'Kembali ke Masuk',
              onPressed: _submitting ? null : () => _switchMode(0),
              icon: Icon(Icons.arrow_back_rounded, color: palette.heading),
            ),
            Text(
              'Daftar Akun',
              style: textTheme.titleLarge?.copyWith(
                color: palette.heading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: palette.primaryCta,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 18,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Hero Copy
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: palette.pillBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 13, color: palette.pillText),
                const SizedBox(width: 5),
                Text(
                  'ENKRIPSI AMAN 256-BIT',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.pillText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Mulai Kelola Finansial Anda',
          style: textTheme.headlineSmall?.copyWith(
            color: palette.heading,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Buat akun pribadi Anda. Rekening Cash awal dan kategori transaksi langsung disiapkan secara otomatis.',
          style: textTheme.bodyMedium?.copyWith(
            color: palette.muted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Register Form Card
        _StitchCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Alamat Email',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: palette.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: palette.pillBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Verifikasi OTP Email',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.pillText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_registerOtpSent) {
                    setState(() => _registerOtpSent = false);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  filled: true,
                  fillColor: palette.inputFill,
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: palette.accent,
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  hintText: 'Minimal 8 karakter',
                  filled: true,
                  fillColor: palette.inputFill,
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: palette.accent,
                  ),
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
              const SizedBox(height: AppSpacing.sm),
              _PasswordStrengthMeter(
                password: _passwordController.text,
                palette: palette,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirmPassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                  hintText: 'Ulangi kata sandi',
                  filled: true,
                  fillColor: palette.inputFill,
                  prefixIcon: Icon(
                    Icons.lock_reset_rounded,
                    color: palette.accent,
                  ),
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
              if (passwordsMatch) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 16,
                      color: palette.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kata sandi cocok',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
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
                      decoration: InputDecoration(
                        labelText: 'Kode OTP Email (6 digit)',
                        hintText: '123456',
                        filled: true,
                        fillColor: palette.inputFill,
                        prefixIcon: Icon(
                          Icons.mark_email_read_outlined,
                          color: palette.accent,
                        ),
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
                        minimumSize: const Size(112, 48),
                      ),
                      child: _sendingOtp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _otpCooldownSeconds > 0
                                  ? 'Kirim (${_otpCooldownSeconds}d)'
                                  : (_registerOtpSent
                                      ? 'Kirim Ulang'
                                      : 'Kirim OTP'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
              if (_registerOtpSent) ...[
                const SizedBox(height: AppSpacing.sm),
                _SuccessBanner(
                  palette: palette,
                  message:
                      'Kode OTP terkirim ke ${_emailController.text.trim()}. Periksa kotak masuk atau folder spam.',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Benefits Card (clean user copy, zero dev strings)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.infoCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: palette.pillBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: palette.pillText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SETELAH PENDAFTARAN BERHASIL:',
                      style: textTheme.labelMedium?.copyWith(
                        color: palette.heading,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _BenefitTile(
                palette: palette,
                icon: Icons.account_balance_wallet_rounded,
                title: 'Rekening Cash Otomatis',
                subtitle: 'Saldo awal Rp 0 siap langsung digunakan',
              ),
              const SizedBox(height: AppSpacing.sm),
              _BenefitTile(
                palette: palette,
                icon: Icons.category_rounded,
                title: '17 Kategori Default',
                subtitle: 'Makanan, Transportasi, Gaji, dan lainnya',
              ),
              const SizedBox(height: AppSpacing.sm),
              _BenefitTile(
                palette: palette,
                icon: Icons.verified_user_rounded,
                title: 'Penyimpanan Terenkripsi Aman',
                subtitle: 'Cadangan cloud & privasi data terjaga',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Terms Checkbox
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  key: const Key('register_terms_checkbox'),
                  value: _acceptedTerms,
                  onChanged: (val) =>
                      setState(() => _acceptedTerms = val ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi Keamanan Data Finansial.',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _ErrorBanner(message: _errorMessage!),
        ],
        const SizedBox(height: AppSpacing.md),

        FilledButton(
          onPressed: _submitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: palette.primaryCta,
            foregroundColor: const Color(0xFFFFFFFF),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFFFFF),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Daftar Akun Sekarang',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              'Sudah memiliki akun?',
              style: textTheme.bodyMedium?.copyWith(color: palette.muted),
            ),
            TextButton(
              onPressed: _submitting ? null : () => _switchMode(0),
              child: Text(
                'Masuk di sini',
                style: TextStyle(
                  color: palette.linkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotPasswordContent(
    BuildContext context,
    _AuthPalette palette,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final emailValid = _isEmailValid(_emailController.text);
    final passwordsMatch = _confirmNewPasswordController.text.isNotEmpty &&
        _confirmNewPasswordController.text == _newPasswordController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Stack Header
        Row(
          children: [
            IconButton(
              tooltip: 'Kembali',
              onPressed: _submitting
                  ? null
                  : () {
                      if (_forgotStep > 0) {
                        setState(() {
                          _forgotStep--;
                          _errorMessage = null;
                        });
                      } else {
                        _switchMode(0);
                      }
                    },
              icon: Icon(Icons.arrow_back_rounded, color: palette.heading),
            ),
            Text(
              'Lupa Kata Sandi',
              style: textTheme.titleLarge?.copyWith(
                color: palette.heading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: palette.primaryCta,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 18,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Hero Padlock Visual Anchor
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.pillBg,
                    boxShadow: [
                      BoxShadow(
                        color: palette.primaryCta.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.primaryCta,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 30,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: palette.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: palette.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: palette.isDark
                              ? const Color(0xFF001F24)
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Lupa Kata Sandi?',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: palette.heading,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Jangan khawatir! Masukkan alamat email yang terdaftar pada akun Anda. Kami akan mengirimkan kode verifikasi OTP 6-digit untuk mereset kata sandi.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildForgotStepper(context, palette),

        // Step 0: Email Request
        if (_forgotStep == 0)
          _StitchCard(
            palette: palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Alamat Email Terdaftar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: palette.heading,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (emailValid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: palette.success.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: palette.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Format Valid',
                              style: textTheme.labelSmall?.copyWith(
                                color: palette.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    filled: true,
                    fillColor: palette.inputFill,
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: palette.accent,
                    ),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Hapus teks email',
                            onPressed: () {
                              _emailController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.cancel_rounded, size: 18),
                          )
                        : null,
                  ),
                  validator: _validateEmail,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primaryCta,
                    foregroundColor: const Color(0xFFFFFFFF),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFFFFF),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Kirim Kode Verifikasi (OTP)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 18),
                          ],
                        ),
                ),
              ],
            ),
          ),

        // Step 1: 6-digit OTP verification
        if (_forgotStep == 1)
          _StitchCard(
            palette: palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: palette.pillBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tahap 2 dari 3',
                            style: textTheme.labelSmall?.copyWith(
                              color: palette.pillText,
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: palette.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Tujuan OTP',
                        style: textTheme.labelSmall?.copyWith(
                          color: palette.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _emailController.text.trim(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: palette.heading,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Masukkan 6 digit angka otentikasi yang dikirimkan ke kotak masuk email Anda.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SixDigitOtpInput(
                  controller: _otpController,
                  focusNode: _forgotOtpFocusNode,
                  palette: palette,
                  validator: _validateOtp,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: palette.inputFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: palette.gold,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kirim ulang kode dalam',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.muted,
                          ),
                        ),
                      ),
                      if (_otpCooldownSeconds > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: palette.cardBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '00:${_otpCooldownSeconds.toString().padLeft(2, '0')}',
                            style: FinancialTypography.tabular(
                              textTheme.labelMedium!,
                            ).copyWith(
                              color: palette.gold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _sendingOtp ? null : _resendForgotOtp,
                          child: const Text('Kirim Ulang OTP'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.inputFill.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        size: 17,
                        color: palette.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demi keamanan akun, kode OTP berlaku selama 10 menit dan hanya dapat digunakan sekali.',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.muted,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primaryCta,
                    foregroundColor: const Color(0xFFFFFFFF),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFFFFF),
                          ),
                        )
                      : const Text(
                          'Verifikasi Kode OTP',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),

        // Step 2: New password
        if (_forgotStep == 2)
          _StitchCard(
            palette: palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: palette.pillBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Tahap 3 dari 3',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.pillText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SuccessBanner(
                  palette: palette,
                  message:
                      'OTP terverifikasi untuk ${_emailController.text.trim()}.',
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    hintText: 'Minimal 8 karakter',
                    filled: true,
                    fillColor: palette.inputFill,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: palette.accent,
                    ),
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
                const SizedBox(height: AppSpacing.sm),
                _PasswordStrengthMeter(
                  password: _newPasswordController.text,
                  palette: palette,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    hintText: 'Ulangi kata sandi baru',
                    filled: true,
                    fillColor: palette.inputFill,
                    prefixIcon: Icon(
                      Icons.lock_reset_rounded,
                      color: palette.accent,
                    ),
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
                if (passwordsMatch) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: palette.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kata sandi cocok',
                        style: textTheme.labelSmall?.copyWith(
                          color: palette.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primaryCta,
                    foregroundColor: const Color(0xFFFFFFFF),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFFFFF),
                          ),
                        )
                      : const Text(
                          'Simpan Kata Sandi Baru',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton.icon(
            onPressed: _submitting ? null : () => _switchMode(0),
            icon: Icon(Icons.arrow_back_rounded, size: 18, color: palette.linkColor),
            label: Text(
              'Kembali ke Halaman Masuk',
              style: TextStyle(
                color: palette.linkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotStepper(BuildContext context, _AuthPalette palette) {
    final textTheme = Theme.of(context).textTheme;
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
                      ? palette.primaryCta
                      : (i < _forgotStep
                          ? palette.success.withValues(alpha: 0.16)
                          : palette.inputFill),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: i == _forgotStep
                        ? palette.primaryCta
                        : (i < _forgotStep
                            ? palette.success.withValues(alpha: 0.45)
                            : palette.cardBorder),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (i < _forgotStep) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: palette.success,
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
                                  ? palette.success
                                  : palette.muted),
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
}

class _AuthPalette {
  const _AuthPalette({
    required this.isDark,
    required this.canvasBg,
    required this.cardBg,
    required this.cardBorder,
    required this.inputFill,
    required this.infoCardBg,
    required this.infoStripBg,
    required this.heading,
    required this.body,
    required this.muted,
    required this.primaryCta,
    required this.primaryGradientStart,
    required this.accent,
    required this.linkColor,
    required this.pillBg,
    required this.pillText,
    required this.gold,
    required this.onGold,
    required this.success,
    required this.biometricActiveBg,
  });

  final bool isDark;
  final Color canvasBg;
  final Color cardBg;
  final Color cardBorder;
  final Color inputFill;
  final Color infoCardBg;
  final Color infoStripBg;
  final Color heading;
  final Color body;
  final Color muted;
  final Color primaryCta;
  final Color primaryGradientStart;
  final Color accent;
  final Color linkColor;
  final Color pillBg;
  final Color pillText;
  final Color gold;
  final Color onGold;
  final Color success;
  final Color biometricActiveBg;

  factory _AuthPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financialColors = Theme.of(context).extension<FinancialColors>();
    if (isDark) {
      return _AuthPalette(
        isDark: true,
        canvasBg: const Color(0xFF091327),
        cardBg: const Color(0xFF121B2F),
        cardBorder: const Color(0xFF1E335A),
        inputFill: const Color(0xFF161F34),
        infoCardBg: const Color(0xFF161F34),
        infoStripBg: const Color(0xFF040E21),
        heading: const Color(0xFFD9E2FE),
        body: const Color(0xFFD9E2FE),
        muted: const Color(0xFF94A3B8),
        primaryCta: const Color(0xFF1E60FF),
        primaryGradientStart: const Color(0xFF1E60FF),
        accent: const Color(0xFF00E3FD),
        linkColor: const Color(0xFFB6C4FF),
        pillBg: const Color(0xFF202A3F),
        pillText: const Color(0xFFB6C4FF),
        gold: const Color(0xFFFFB95F),
        onGold: const Color(0xFF2A1700),
        success: financialColors?.income ?? const Color(0xFF4ADE80),
        biometricActiveBg: const Color(0xFF202A3F),
      );
    }

    return _AuthPalette(
      isDark: false,
      canvasBg: const Color(0xFFFAF8FF),
      cardBg: const Color(0xFFFFFFFF),
      cardBorder: const Color(0xFFEAEDFF),
      inputFill: const Color(0xFFF2F3FF),
      infoCardBg: const Color(0xFFF2F3FF),
      infoStripBg: const Color(0xFFEAEDFF),
      heading: const Color(0xFF001430),
      body: const Color(0xFF131B2E),
      muted: const Color(0xFF43474F),
      primaryCta: const Color(0xFF0054CC),
      primaryGradientStart: const Color(0xFF002855),
      accent: const Color(0xFF0054CC),
      linkColor: const Color(0xFF0054CC),
      pillBg: const Color(0xFFE2E7FF),
      pillText: const Color(0xFF0040A1),
      gold: const Color(0xFFFFB956),
      onGold: const Color(0xFF2A1800),
      success: financialColors?.income ?? const Color(0xFF00A86B),
      biometricActiveBg: const Color(0xFFF2F3FF),
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.palette});

  final _AuthPalette palette;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -50,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.primaryCta
                          .withValues(alpha: palette.isDark ? 0.18 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.accent
                          .withValues(alpha: palette.isDark ? 0.14 : 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StitchCard extends StatelessWidget {
  const _StitchCard({
    required this.palette,
    required this.child,
  });

  final _AuthPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: palette.isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF001430).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({
    required this.password,
    required this.palette,
  });

  final String password;
  final _AuthPalette palette;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    if (password.isNotEmpty && score == 0) score = 1;

    final (label, barColor) = switch (score) {
      0 => ('Belum diisi', palette.muted),
      1 => ('Lemah: Minimal 8 karakter', const Color(0xFFEF4444)),
      2 => ('Cukup: Tambah angka/huruf besar', const Color(0xFFF59E0B)),
      3 => ('Kuat: Hampir lengkap', palette.primaryCta),
      _ => ('Sangat Kuat: Huruf besar, angka & simbol', palette.success),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.isDark ? const Color(0xFF040E21) : palette.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Kekuatan Sandi',
                style: textTheme.labelSmall?.copyWith(color: palette.muted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: textTheme.labelSmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < score
                          ? barColor
                          : palette.cardBorder.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SixDigitOtpInput extends StatelessWidget {
  const _SixDigitOtpInput({
    required this.controller,
    required this.focusNode,
    required this.palette,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final _AuthPalette palette;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final code = controller.text.trim();

    return FormField<String>(
      validator: (_) => validator(controller.text),
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 54,
            child: Stack(
              children: [
                IgnorePointer(
                  child: Row(
                    children: [
                      for (var i = 0; i < 6; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: i < code.length
                                  ? palette.pillBg
                                  : palette.inputFill,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: focusNode.hasFocus && i == code.length
                                    ? palette.accent
                                    : (field.hasError
                                        ? colorScheme.error
                                        : palette.cardBorder),
                                width: focusNode.hasFocus && i == code.length
                                    ? 1.8
                                    : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                i < code.length ? code[i] : '•',
                                style: FinancialTypography.tabular(
                                  textTheme.titleLarge!,
                                ).copyWith(
                                  color: i < code.length
                                      ? palette.heading
                                      : palette.muted,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned.fill(
                  child: TextField(
                    key: const Key('forgot_otp_field'),
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    showCursor: false,
                    cursorColor: Colors.transparent,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 1,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (val) => field.didChange(val),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (field.hasError) ...[
            const SizedBox(height: 6),
            Text(
              field.errorText!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final _AuthPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.pillBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 19, color: palette.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: palette.heading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({
    required this.palette,
    required this.message,
  });

  final _AuthPalette palette;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: palette.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: palette.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: palette.body,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
