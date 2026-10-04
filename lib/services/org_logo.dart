import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';

/// تخزين شعار النقابة.
///  - أندرويد: ملف داخل مجلد التطبيق + مساره في settings (org_logo_path).
///  - الويب: لا نظام ملفات، فيُحفظ الشعار Base64 في settings (org_logo_b64).
class OrgLogo {
  static const _pathKey = 'org_logo_path';
  static const _b64Key = 'org_logo_b64';

  static Future<String?> _get(String key) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('settings',
        columns: ['setting_value'],
        where: 'setting_key = ?',
        whereArgs: [key],
        limit: 1);
    return rows.isEmpty ? null : rows.first['setting_value'] as String?;
  }

  static Future<void> _put(String key, String value) async {
    final db = await AppDatabase.instance.database;
    await db.insert('settings', {'setting_key': key, 'setting_value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> _del(String key) async {
    final db = await AppDatabase.instance.database;
    await db.delete('settings', where: 'setting_key = ?', whereArgs: [key]);
  }

  /// بايتات الشعار الحالي أو null إن لم يوجد.
  static Future<Uint8List?> load() async {
    try {
      if (kIsWeb) {
        final b64 = await _get(_b64Key);
        if (b64 == null || b64.isEmpty) return null;
        return base64Decode(b64);
      }
      final path = await _get(_pathKey);
      if (path == null || path.isEmpty) return null;
      final f = File(path);
      if (!await f.exists()) return null;
      return await f.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Uint8List bytes, {String extension = '.png'}) async {
    if (kIsWeb) {
      await _put(_b64Key, base64Encode(bytes));
      return;
    }
    final d = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(d.path, 'organization'));
    await dir.create(recursive: true);
    final target = File(p.join(dir.path, 'logo$extension'));
    await target.writeAsBytes(bytes, flush: true);
    await _put(_pathKey, target.path);
  }

  static Future<void> remove() async {
    if (kIsWeb) {
      await _del(_b64Key);
      return;
    }
    final path = await _get(_pathKey);
    await _del(_pathKey);
    if (path != null) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }
}
