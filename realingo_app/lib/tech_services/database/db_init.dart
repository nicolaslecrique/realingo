import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:realingo_app/tech_services/database/schema.dart';
import 'package:sqflite/sqflite.dart';

// activate foreign keys
Future<void> _onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

Future<void> _onCreate(Database db, int version) async {
  Batch batch = db.batch();
  batch.execute(DB.learningProgram.getCreateQuery());
  batch.execute(DB.itemToLearn.getCreateQuery());
  batch.execute(DB.userProgram.getCreateQuery());
  return await batch.commit();
}

Future<void> deleteDb() async {
  // cf. https://flutter.dev/docs/cookbook/persistence/sqlite
  WidgetsFlutterBinding.ensureInitialized();

  String dbPath = join(await getDatabasesPath(), 'realingo_db.db');
  if (await databaseExists(dbPath)) {
    await deleteDatabase(dbPath);
  }
}

Future<Database> initDb() async {
  // cf. https://flutter.dev/docs/cookbook/persistence/sqlite
  WidgetsFlutterBinding.ensureInitialized();

  String dbPath = join(await getDatabasesPath(), 'realingo_db.db');
  Database db = await openDatabase(dbPath, version: 1, onConfigure: _onConfigure, onCreate: _onCreate);

  return db;
}
