import 'package:either_dart/either.dart';
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

class MessageError {
  Object message;

  MessageError(this.message);
}

class FileUploader extends ChangeNotifier {
  String token;
  List<ProcessedFile> files = <ProcessedFile>[];
  final keys = <String>{};

  FileUploader(this.token);

  void addFile(MemoryFile image, MemoryFile mask) {
    // final uniqueKey = md5.convert(file.data).toString();
    // if (keys.contains(uniqueKey)) {
    //   print('file ${file.filename} contains');
    //   return;
    // }

    // // todo: process file to server
    // keys.add(uniqueKey);
    // print(uniqueKey);
    // files.add(ProcessedFile(
    //   id: uniqueKey,
    //   filename: file.filename,
    //   state: FileProcess.processing,
    // ));

    notifyListeners();
  }

  void removeFile(String key) {
    notifyListeners();
  }

  void downloadFile() {
    notifyListeners();
  }

  Future<Either<MessageError, MemoryFile>> getFile(String key) async {
    notifyListeners();
    return Left(MessageError('Not implemented'));
  }
}
