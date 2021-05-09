import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/pages/preview_image.dart';
import 'package:web/widgets/watermark_form.dart';
import 'package:web/stores/auth_store.dart';
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
        Container(width: 400, child: FilesView()),
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
    final authToken = context.watch<AuthStore>().token;
    return Row(children: [
      Expanded(
        child: Text(file.filename, style: theme.textTheme.headline6),
      ),
      IconButton(
          icon: Icon(Icons.file_download),
          onPressed: fileReady
              ? () {
                  // todo download
                }
              : null),
      IconButton(
        icon: Icon(Icons.preview),
        onPressed: fileReady
            ? () {
                final url = '/api/image/$authToken/${file.id}';
                final imageProvider = NetworkImage(url);
                showDialog(
                  context: context,
                  builder: (context) =>
                      ImagePreview(imageProvider: imageProvider),
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
