import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:web/stores/files_loader_store.dart';
import 'package:web/widgets/drop_zone.dart';
import 'package:web/config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: "home",
      routes: {
        "home": (context) => MainPage(),
      },
    );
  }
}

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
      body: Observer(builder: buildBody),
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
        color: state == DropState.hover ? Theme.of(context).accentColor.withAlpha(20) : null,
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(25),
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
    return ListTile(
      trailing: Icon(Icons.clear),
      title: Text(file.filename),
    );
  }
}
