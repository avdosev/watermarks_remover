// ignore: import_of_legacy_library_into_null_safe
import 'package:mobx/mobx.dart';

part 'files_loader_store.g.dart';

class FileUploader = FileUploaderBase with _$FileUploader;

// States

enum FileProcess { none, loading, processing, done }

class ProcessedFile {
  final String filename;
  FileProcess state;

  ProcessedFile(this.filename, this.state);
}

abstract class FileUploaderBase with Store {
  @observable
  ObservableList<ProcessedFile> files = ObservableList<ProcessedFile>();

  @action
  void addFile(file) {}
}
