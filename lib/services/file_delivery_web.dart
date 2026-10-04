import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

String _mimeFor(String name) {
  final n = name.toLowerCase();
  if (n.endsWith('.pdf')) return 'application/pdf';
  if (n.endsWith('.csv')) return 'text/csv;charset=utf-8';
  if (n.endsWith('.xlsx')) {
    return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  }
  if (n.endsWith('.db')) return 'application/octet-stream';
  return 'application/octet-stream';
}

Future<void> deliverFile(String fileName, List<int> bytes, {String? text}) async {
  final safeName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '').trim();
  final blob = web.Blob(
    [Uint8List.fromList(bytes).toJS].toJS,
    web.BlobPropertyBag(type: _mimeFor(safeName)),
  );
  final url = web.URL.createObjectURL(blob);
  final a = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = safeName;
  a.style.display = 'none';
  web.document.body!.append(a);
  a.click();
  a.remove();
  // تأخير بسيط حتى يبدأ التنزيل قبل إلغاء الرابط المؤقت.
  await Future<void>.delayed(const Duration(seconds: 2));
  web.URL.revokeObjectURL(url);
}
