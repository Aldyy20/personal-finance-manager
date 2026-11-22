import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class ActiveWorkspaceSession {
  const ActiveWorkspaceSession({
    required this.userId,
    required this.deviceId,
    required this.name,
    required this.email,
    required this.isCloudAuthenticated,
  });

  final String userId;
  final String deviceId;
  final String name;
  final String email;
  final bool isCloudAuthenticated;

  static const offlineGuestUserId = 'local-offline-user';
}

class SessionController extends AsyncNotifier<ActiveWorkspaceSession> {
  @override
  Future<ActiveWorkspaceSession> build() async {
    return _loadSession();
  }

  Future<ActiveWorkspaceSession> _loadSession() async {
    final authRepo = ref.read(authRepositoryProvider);
    final ledger = ref.read(localLedgerServiceProvider);
    final db = ref.read(appDatabaseProvider);

    final offlineSession = await authRepo.getOfflineSession();
    if (offlineSession != null) {
      final user = await (db.select(db.localUsers)
            ..where((t) => t.id.equals(offlineSession.userId)))
          .getSingleOrNull();
      return ActiveWorkspaceSession(
        userId: offlineSession.userId,
        deviceId: offlineSession.deviceId,
        name: user?.name ?? offlineSession.email.split('@').first,
        email: offlineSession.email,
        isCloudAuthenticated: true,
      );
    }

    const guestId = ActiveWorkspaceSession.offlineGuestUserId;
    await ledger.ensureDefaultOfflineWorkspace(guestId);
    final guestUser = await (db.select(db.localUsers)
          ..where((t) => t.id.equals(guestId)))
        .getSingleOrNull();
    final deviceId = await authRepo.ensureDeviceId();

    return ActiveWorkspaceSession(
      userId: guestId,
      deviceId: deviceId,
      name: guestUser?.name ?? 'Dompet Pribadi',
      email: guestUser?.email ?? 'mode.lokal@offline',
      isCloudAuthenticated: false,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final authRepo = ref.read(authRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final authSession = await authRepo.login(
      email: email,
      password: password,
      pullInitialData: true,
    );
    final user = await (db.select(db.localUsers)
          ..where((t) => t.id.equals(authSession.userId)))
        .getSingleOrNull();

    state = AsyncData(
      ActiveWorkspaceSession(
        userId: authSession.userId,
        deviceId: authSession.deviceId,
        name: user?.name ?? email.split('@').first,
        email: authSession.email,
        isCloudAuthenticated: true,
      ),
    );
    await ref.read(syncStatusProvider.notifier).refreshLocalState();
  }

  Future<void> register({
    String? name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String otpCode,
  }) async {
    final authRepo = ref.read(authRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final authSession = await authRepo.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      otpCode: otpCode,
      pullInitialData: true,
    );
    final user = await (db.select(db.localUsers)
          ..where((t) => t.id.equals(authSession.userId)))
        .getSingleOrNull();

    state = AsyncData(
      ActiveWorkspaceSession(
        userId: authSession.userId,
        deviceId: authSession.deviceId,
        name: user?.name ??
            ((name != null && name.trim().isNotEmpty)
                ? name.trim()
                : email.split('@').first),
        email: authSession.email,
        isCloudAuthenticated: true,
      ),
    );
    await ref.read(syncStatusProvider.notifier).refreshLocalState();
  }

  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    state = const AsyncLoading();
    state = AsyncData(await _loadSession());
    await ref.read(syncStatusProvider.notifier).refreshLocalState();
  }

  Future<void> updateProfileName(String newName) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final ledger = ref.read(localLedgerServiceProvider);
    await ledger.updateLocalProfileName(current.userId, newName);

    if (current.isCloudAuthenticated) {
      try {
        await ref.read(apiClientProvider).put(
          '/profile',
          data: {'name': newName.trim()},
        );
      } catch (_) {
        // Keep local update if offline; cloud profile edit can retry later.
      }
    }

    state = AsyncData(
      ActiveWorkspaceSession(
        userId: current.userId,
        deviceId: current.deviceId,
        name: newName.trim(),
        email: current.email,
        isCloudAuthenticated: current.isCloudAuthenticated,
      ),
    );
  }
}

