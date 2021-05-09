import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:web/memory_file.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// States

enum FileProcess { none, loading, processing, done }

class ProcessedFile {
  final String id;
  final String filename;
  final FileProcess state;

  const ProcessedFile({
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
  bool _update = false;
  String token;
  List<ProcessedFile> files = <ProcessedFile>[];

  FileUploader(this.token);

  void addFile(MemoryFile image, MemoryFile mask) async {
    final uri = Uri.base.replace(path: '/api/image/$token');
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('image', image.data,
          filename: image.filename))
      ..files.add(http.MultipartFile.fromBytes('mask', mask.data,
          filename: mask.filename));
    await request.send();
  }

  void removeFile(String key) {
    final uri = Uri.base.replace(path: '/api/image/$token/$key');
    http.delete(uri);
  }

  Uri getFileUrl(String key) {
    final uri = Uri.base.replace(path: '/api/image/$token/$key');
    return uri;
  }

  void startUpdating() {
    _updateFiles();
  }

  void _updateFiles() async {
    _update = true;
    while (_update) {
      try {
        final status = await getStatus();
        files = status;
        notifyListeners();
      } catch (err) {
        print('Files status error: $err');
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  void dispose() {
    _update = false;
    super.dispose();
  }

  Future<List<ProcessedFile>> getStatus() async {
    final url = Uri.base.replace(path: '/api/images/info/$token');
    final response = await http.get(url);
    final res = json.decode(response.body);
    final files = <ProcessedFile>[];
    for (final item in res) {
      late FileProcess status;
      switch (item['status']) {
        case 'IN_PROGRESS':
          status = FileProcess.processing;
          break;
        case 'READY':
          status = FileProcess.done;
          break;
        default:
          status = FileProcess.none;
      }
      files.add(ProcessedFile(
          id: item['id'], filename: item['image_name'], state: status));
    }
    return files;
  }
}
