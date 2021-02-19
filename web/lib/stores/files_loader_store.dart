// ignore: import_of_legacy_library_into_null_safe
import 'package:mobx/mobx.dart';
import 'package:web/memory_file.dart';
import 'package:crypto/crypto.dart';

part 'files_loader_store.g.dart';

class FileUploader = FileUploaderBase with _$FileUploader;

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

abstract class FileUploaderBase with Store {
  @observable
  ObservableList<ProcessedFile> files = ObservableList<ProcessedFile>();
  final keys = <String>{};

  @action
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
  }
}
