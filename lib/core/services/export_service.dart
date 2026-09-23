import 'platform_export_stub.dart'
    if (dart.library.js_interop) 'platform_export_web.dart'
    as platform;

bool downloadTextFile({
  required String filename,
  required String content,
  String mimeType = 'text/plain;charset=utf-8',
}) => platform.downloadTextFile(
  filename: filename,
  content: content,
  mimeType: mimeType,
);

bool printCurrentPage() => platform.printCurrentPage();

String calendarTimestamp(DateTime value) {
  final utc = value.toUtc();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${utc.year}${two(utc.month)}${two(utc.day)}T'
      '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
}

String csvCell(Object? value) {
  final text = value?.toString() ?? '';
  return '"${text.replaceAll('"', '""')}"';
}
