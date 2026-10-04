// تسليم ملف ناتج (PDF/CSV/Excel) للمستخدم:
//  - أندرويد/iOS: ملف مؤقت + نافذة المشاركة (السلوك الأصلي).
//  - الويب: تنزيل مباشر عبر المتصفح.
export 'file_delivery_io.dart' if (dart.library.js_interop) 'file_delivery_web.dart';
