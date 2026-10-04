import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// على الويب نستخدم SQLite (WASM) بدون Web Worker: يلزمه فقط ملف
/// web/sqlite3.wasm الذي يولّده الأمر
/// `dart run sqflite_common_ffi_web:setup` أثناء البناء (انظر build-web.yml).
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
