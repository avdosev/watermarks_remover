import 'package:flutter/material.dart';
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
        primarySwatch: Colors.blue,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.homeTitle),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 400,
            height: 400,
            child: DropZone(
              builder: dropZoneBuilder,
              onFile: (file) {
                print('${file.mime} file ${file.filename}');
              },
            ),
          )
        ],
      ),
    );
  }

  Widget dropZoneBuilder(context, state) {
    final textStyle = TextStyle(fontSize: 25);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('Drop file there', style: textStyle),
    );
  }
}
