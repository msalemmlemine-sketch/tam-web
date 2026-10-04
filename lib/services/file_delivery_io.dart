import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> deliverFile(String fileName, List<int> bytes, {String? text}) async {
  final dir = await getTemporaryDirectory();
  final safeName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '').trim();
  final file = File(p.join(dir.path, safeName));
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles([XFile(file.path)], text: text ?? fileName);
}
