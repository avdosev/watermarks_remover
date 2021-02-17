import 'dart:typed_data';

class MemoryFile {
  final String filename;
  final String mime;
  final Uint8List data;

  MemoryFile({
    required this.filename,
    required this.mime,
    required this.data,
  });
}
