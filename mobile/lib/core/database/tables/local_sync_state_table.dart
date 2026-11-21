import 'package:drift/drift.dart';

class LocalSyncState extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get deviceId => text()();
  IntColumn get lastCursor => integer().withDefault(const Constant(0))();
  IntColumn get lastSyncAtMs => integer().nullable()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

