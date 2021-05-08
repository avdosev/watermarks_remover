import 'package:flutter/material.dart';
import 'package:web/memory_file.dart';
import 'package:crypto/crypto.dart';

// States

enum FileProcess { none, loading, processing, done }

class ProcessedFile {
  final String id;
  final String filename;
  FileProcess state;

  ProcessedFile({
    required this.id,
    required this.filename,
    required this.state,
  });
}

class FileUploader extends ChangeNotifier {
  List<ProcessedFile> files = <ProcessedFile>[];
  final keys = <String>{};

  void addFile(MemoryFile file) {
    final uniqueKey = md5.convert(file.data).toString();
    if (keys.contains(uniqueKey)) {
      print('file ${file.filename} contains');
      return;
    }

    // todo: process file to server
    keys.add(uniqueKey);
    print(uniqueKey);
    files.add(ProcessedFile(
      id: uniqueKey,
      filename: file.filename,
      state: FileProcess.processing,
    ));

    notifyListeners();
  }
}
