import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
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
  late DropzoneViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.homeTitle),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                DropzoneView(
                  operation: DragOperation.copy,
                  cursor: CursorType.auto,
                  onCreated: (ctrl) => controller = ctrl,
                  onLoaded: () => print('Zone loaded'),
                  onError: (ev) => print('Error: $ev'),
                  onHover: () => print('Zone hovered'),
                  onDrop: (ev) => print('Drop: $ev'),
                  onLeave: () => print('Zone left'),
                ),
                Center(child: Text('Drop files here')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
