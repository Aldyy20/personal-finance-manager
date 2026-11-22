import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/finance_widgets.dart';
import '../features/authentication/presentation/auth_screen.dart';
import 'providers.dart';
import 'router.dart';

class PersonalFinanceApp extends ConsumerStatefulWidget {
  const PersonalFinanceApp({super.key});

  @override
  ConsumerState<PersonalFinanceApp> createState() => _PersonalFinanceAppState();
}

class _PersonalFinanceAppState extends ConsumerState<PersonalFinanceApp>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;
  bool _hasResolvedInitialSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!ref.read(biometricPromptActiveProvider)) {
        _pausedAt ??= DateTime.now();
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt == null) return;

      final elapsed = DateTime.now().difference(pausedAt);
      final isAuthenticated =
          ref.read(activeSessionProvider).valueOrNull?.isCloudAuthenticated ??
              false;
      if (elapsed >= const Duration(seconds: 30) &&
          !ref.read(biometricPromptActiveProvider) &&
          isAuthenticated) {
        ref.read(appUnlockedProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Personal Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final sessionAsync = ref.watch(activeSessionProvider);
        final isAppUnlocked = ref.watch(appUnlockedProvider);
        if (sessionAsync.hasValue) {
          _hasResolvedInitialSession = true;
        }

        if (!_hasResolvedInitialSession && sessionAsync.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogoBadge(size: 64, borderRadius: 18),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        final session = sessionAsync.valueOrNull;
        if (session != null && session.isCloudAuthenticated && !isAppUnlocked) {
          return HeroControllerScope.none(
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const AuthScreen(isAppLockMode: true),
              ),
            ),
          );
        }

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

