import 'package:sqflite/sqflite.dart';

Future<Database> openNotesDb() async {
  final path = await getDatabasesPath();
  return openDatabase(
    '$path/notes.db',
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, updated_at TEXT, dirty INTEGER)',
      );
    },
  );
}