import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/stores/files_loader_store.dart';
import 'package:web/widgets/drop_zone.dart';
import 'package:web/config.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final filesStore = FileUploader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.homeTitle),
      ),
      body: ChangeNotifierProvider(
        create: (context) => filesStore,
        child: Consumer<FileUploader>(
            builder: (context, __, ___) => buildBody(context)),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final hasFiles = filesStore.files.isNotEmpty;
    if (hasFiles) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Center(child: buildDropZone())),
          Container(width: 400, child: buildFiles(context)),
        ],
      );
    } else {
      return Center(child: buildDropZone());
    }
  }

  Widget buildDropZone() {
    return DropZone(
      builder: dropZoneBuilder,
      onFile: (file) {
        print('${file.mime} file ${file.filename}');
        filesStore.addFile(file);
      },
    );
  }

  Widget dropZoneBuilder(context, state) {
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

  Widget buildFiles(BuildContext context) {
    final files = filesStore.files;
    return ListView.builder(
      itemBuilder: (context, index) =>
          buildFileStatusItem(context, files[index]),
      itemCount: files.length,
    );
  }

  Widget buildFileStatusItem(BuildContext context, ProcessedFile file) {
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
