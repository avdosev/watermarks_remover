import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/stores/files_loader_store.dart';
import 'package:web/widgets/drop_zone.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            child: Center(
                child: WatermarkLoaderForm(key: ValueKey('input_form')))),
        Container(width: 400, child: FilesView()),
      ],
    );
  }
}

class WatermarkLoaderForm extends StatefulWidget {
  final Key? key;

  WatermarkLoaderForm({this.key}) : super(key: key);

  @override
  _WatermarkLoaderFormState createState() => _WatermarkLoaderFormState();
}

class _WatermarkLoaderFormState extends State<WatermarkLoaderForm> {
  @override
  Widget build(BuildContext context) {
    final filesStore = context.watch<FileUploader>();
    return DropZone(
      builder: dropZoneBuilder,
      onFile: (file) {
        print('${file.mime} file ${file.filename}');
        filesStore.addFile(file);
      },
    );
  }

  Widget dropZoneBuilder(BuildContext context, DropState state) {
    final textStyle = TextStyle(fontSize: 25);
    return Container(
      height: 400,
      width: 400,
      decoration: BoxDecoration(
        // color: state == DropState.hover
        //     ? Theme.of(context).accentColor.withAlpha(20)
        //     : null,
        color: Color.fromRGBO(0xee, 0xeb, 0xf4, 1),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          if (state == DropState.hover)
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('Drop file there', style: textStyle),
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
    return Row(children: [
      Expanded(
        child: Text(file.filename, style: theme.textTheme.headline6),
      ),
      IconButton(
        icon: Icon(Icons.preview),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => filesStore.removeFile(file.id),
      )
    ]);
  }
}
