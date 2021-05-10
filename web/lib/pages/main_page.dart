import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/pages/preview_image.dart';
import 'package:web/utils/file_download.dart';
import 'package:web/widgets/watermark_form.dart';
import 'package:web/stores/files_loader_store.dart';
import 'package:web/config.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.homeTitle),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final filesStore = context.watch<FileUploader>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: 400,
          padding: EdgeInsets.only(left: 10),
          child: FilesView(),
        ),
        Expanded(
          child: Center(
            child: WatermarkLoaderForm(
              key: ValueKey('input_form'),
              onSubmit: (image, mask) => filesStore.addFile(image, mask),
            ),
          ),
        ),
      ],
    );
  }
}

class FilesView extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<FileUploader>(
      builder: (context, filesStore, __) {
        final files = filesStore.files;
        return ListView.builder(
          itemBuilder: (context, index) =>
              buildFileStatusItem(context, files[index], filesStore),
          itemCount: files.length,
        );
      },
    );
  }

  Widget buildFileStatusItem(
      BuildContext context, ProcessedFile file, FileUploader filesStore) {
    final theme = Theme.of(context);
    final fileReady = file.state == FileProcess.done;
    late Icon fileStatus;
    if (file.state == FileProcess.done) {
      fileStatus = Icon(
        Icons.done,
        semanticLabel: 'Завершено',
      );
    } else if (file.state == FileProcess.processing) {
      fileStatus = Icon(
        Icons.cached,
        semanticLabel: 'Обрабатывается',
      );
    } else {
      fileStatus = Icon(
        Icons.query_builder,
        semanticLabel: 'Ожидание',
      );
    }
    return Row(children: [
      fileStatus,
      Expanded(
        child: Text(file.filename, style: theme.textTheme.headline6),
      ),
      IconButton(
          icon: Icon(Icons.file_download),
          onPressed: fileReady
              ? () {
                  downloadFile(filesStore.getFileUrl(file.id), file.filename);
                }
              : null),
      IconButton(
        icon: Icon(Icons.preview),
        onPressed: fileReady
            ? () {
                final url = filesStore.getFileUrl(file.id).toString();
                final imageProvider = NetworkImage(url);
                showDialog(
                  context: context,
                  builder: (context) =>
                      Dialog(child: ImagePreview(imageProvider: imageProvider)),
                );
              }
            : null,
      ),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => filesStore.removeFile(file.id),
      )
    ]);
  }
}
