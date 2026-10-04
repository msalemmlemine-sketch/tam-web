// يختار مصنع قاعدة البيانات المناسب للمنصّة:
//  - أندرويد/iOS: لا شيء (sqflite الأصلي يعمل مباشرة).
//  - الويب: SQLite مُجمَّعة WebAssembly تُحفظ داخل IndexedDB في المتصفح.
export 'db_factory_stub.dart' if (dart.library.js_interop) 'db_factory_web.dart';
