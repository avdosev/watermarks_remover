import 'package:universal_html/html.dart' as html;

void downloadFile(Uri url, String filename) {
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url.toString()
    ..style.display = 'none'
    ..download = filename;

  html.document.body?.children.add(anchor);

  // download
  anchor.click();

  html.document.body?.children.remove(anchor);
}
