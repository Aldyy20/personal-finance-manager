import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/dashboard/presentation/foundation_home_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const FoundationHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                builder: (context, state) => const _ModulePlaceholderScreen(
                  title: 'Transactions',
                  phaseNote: 'Implementasi penuh pada Phase 4/6 (Income, Expense, Transfer, OCR).',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                name: 'accounts',
                builder: (context, state) => const _ModulePlaceholderScreen(
                  title: 'Accounts',
                  phaseNote: 'Implementasi penuh pada Phase 4/6 (Cash, Bank, E-Wallet, Ledger).',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const _ModulePlaceholderScreen(
                  title: 'Reports',
                  phaseNote: 'Implementasi penuh pada Phase 6 (Charts, Budget & PDF/Excel Export).',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const _ModulePlaceholderScreen(
                  title: 'Settings',
                  phaseNote: 'Implementasi penuh pada Phase 6 (Profile, Theme, Sync, Devices).',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _ModulePlaceholderScreen extends StatelessWidget {
  const _ModulePlaceholderScreen({
    required this.title,
    required this.phaseNote,
  });

  final String title;
  final String phaseNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            phaseNote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

