import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'dart:io';

part 'drift_database.g.dart';

class History extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 1024)();
  TextColumn get address => text().withLength(min: 0, max: 1024)();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [History])
class SerenDatabase extends _$SerenDatabase {
  SerenDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<HistoryData>> get getHistory => select(history).get();

  Future<void> addHistory(String title, String address) async {
    into(history).insert(HistoryCompanion(
      title: Value(title),
      address: Value(address)
    ));
  }
}