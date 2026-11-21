enum SyncStateStatus {
  idle,
  syncing,
  synced,
  offline,
  conflict,
  error,
}

class SyncStatusInfo {
  const SyncStatusInfo({
    required this.status,
    this.pendingCount = 0,
    this.lastCursor = 0,
    this.lastSyncAt,
    this.lastError,
  });

  final SyncStateStatus status;
  final int pendingCount;
  final int lastCursor;
  final DateTime? lastSyncAt;
  final String? lastError;
}

