import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/local_sync_state_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalSyncState])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// Verifies that the local SQLite database is operational.
  Future<bool> checkDatabaseHealth() async {
    final result = await customSelect('SELECT 1 AS ok').getSingle();
    return result.read<int>('ok') == 1;
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'personal_finance_manager.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

