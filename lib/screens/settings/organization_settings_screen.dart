import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../services/org_logo.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});
  @override
  State<OrganizationSettingsScreen> createState() => _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState extends State<OrganizationSettingsScreen> {
  Uint8List? _logo;
  bool _busy = true;
  bool _savingNames = false;

  final _orgSecretaryCtrl = TextEditingController();
  final _financeSecretaryCtrl = TextEditingController();
  final _regionalCaptainCtrl = TextEditingController();

  static const _kOrgSecretaryKey = 'organization_secretary_name';
  static const _kFinanceSecretaryKey = 'finance_secretary_name';
  static const _kRegionalCaptainKey = 'regional_captain_name';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _orgSecretaryCtrl.dispose();
    _financeSecretaryCtrl.dispose();
    _regionalCaptainCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = await AppDatabase.instance.database;
    final logo = await OrgLogo.load();
    final nameRows = await db.query('settings', where: 'setting_key IN (?, ?, ?)', whereArgs: [
      _kOrgSecretaryKey,
      _kFinanceSecretaryKey,
      _kRegionalCaptainKey,
    ]);
    final names = {for (final r in nameRows) r['setting_key'] as String: r['setting_value'] as String?};
    if (!mounted) return;
    setState(() {
      _logo = logo;
      _orgSecretaryCtrl.text = names[_kOrgSecretaryKey] ?? '';
      _financeSecretaryCtrl.text = names[_kFinanceSecretaryKey] ?? '';
      _regionalCaptainCtrl.text = names[_kRegionalCaptainKey] ?? '';
      _busy = false;
    });
  }

  Future<void> _saveNames() async {
    setState(() => _savingNames = true);
    final db = await AppDatabase.instance.database;
    final entries = {
      _kOrgSecretaryKey: _orgSecretaryCtrl.text.trim(),
      _kFinanceSecretaryKey: _financeSecretaryCtrl.text.trim(),
      _kRegionalCaptainKey: _regionalCaptainCtrl.text.trim(),
    };
    for (final entry in entries.entries) {
      if (entry.value.isEmpty) {
        await db.delete('settings', where: 'setting_key = ?', whereArgs: [entry.key]);
      } else {
        await db.insert('settings', {'setting_key': entry.key, 'setting_value': entry.value}, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    if (mounted) {
      setState(() => _savingNames = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ أسماء الموقّعين')));
    }
  }

  Future<void> _pick() async {
    final pck = await FilePicker.pickFiles(type: FileType.image);
    if (pck.isEmpty) return;
    setState(() => _busy = true);
    try {
      final f = pck.single;
      final bytes = await f.readAsBytes();
      final name = f.name;
      final dot = name.lastIndexOf('.');
      final ext = dot >= 0 ? name.substring(dot) : '.png';
      await OrgLogo.save(bytes, extension: ext);
      if (mounted) setState(() { _logo = bytes; _busy = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر حفظ الشعار: $e')));
      }
    }
  }

  Future<void> _remove() async {
    await OrgLogo.remove();
    if (mounted) setState(() => _logo = null);
  }

  @override
  Widget build(BuildContext context) {
    final has = _logo != null;
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات النقابة')),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('الشعار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Center(
                  child: has
                      ? Image.memory(_logo!, width: 160, height: 160, fit: BoxFit.contain)
                      : const Icon(Icons.image_outlined, size: 100),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _pick,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(has ? 'تغيير الشعار' : 'اختيار الشعار'),
                  ),
                ),
                if (has)
                  OutlinedButton.icon(
                    onPressed: _remove,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('حذف الشعار'),
                  ),
                const Divider(height: 36),
                const Text('أسماء الموقّعين في التقارير واللوائح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('تُستخدم هذه الأسماء في توقيعات كل التقارير الصادرة من التطبيق.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: _orgSecretaryCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'اسم أمين التنظيم', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _financeSecretaryCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'اسم أمين المالية', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regionalCaptainCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'اسم النقيب الجهوي', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _savingNames ? null : _saveNames,
                    icon: _savingNames
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: const Text('حفظ الأسماء'),
                  ),
                ),
              ],
            ),
    );
  }
}
