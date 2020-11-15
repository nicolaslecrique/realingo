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

Future<String> get dbPath async => join(await getDatabasesPath(), 'realingo_db.db');

Future<void> deleteDb() async {
  // cf. https://flutter.dev/docs/cookbook/persistence/sqlite
  WidgetsFlutterBinding.ensureInitialized();
  String path = await dbPath;
  if (await databaseExists(path)) {
    await deleteDatabase(path);
  }
}

// parametrized on databaseFactory and path for unit testing
Future<Database> initDb(DatabaseFactory databaseFactory, String dbPath) async {
  // cf. https://flutter.dev/docs/cookbook/persistence/sqlite
  WidgetsFlutterBinding.ensureInitialized();

  Database db = await databaseFactory.openDatabase(dbPath,
      options: OpenDatabaseOptions(version: 1, onConfigure: _onConfigure, onCreate: _onCreate));

  return db;
}
