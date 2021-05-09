import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../memory_file.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class WatermarkLoaderForm extends StatefulWidget {
  final Key? key;
  final void Function(MemoryFile image, MemoryFile mask) onSubmit;

  WatermarkLoaderForm({this.key, required this.onSubmit}) : super(key: key);

  @override
  _WatermarkLoaderFormState createState() => _WatermarkLoaderFormState();
}

class _WatermarkLoaderFormState extends State<WatermarkLoaderForm> {
  DropzoneViewController? controller;
  MemoryFile? image;
  MemoryFile? mask;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DropzoneView(
        onCreated: (ctrl) => controller = ctrl,
        onLoaded: () => print('Zone loaded'),
        onError: (ev) => print('Error: $ev'),
        onDrop: (ev) async {},
      ),
      buildForm(context),
    ]);
  }

  Widget buildForm(BuildContext context) {
    return Container(
      height: 400,
      width: 400,
      decoration: BoxDecoration(
        color: Color.fromRGBO(0xee, 0xeb, 0xf4, 1),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          FileForm(
            file: image,
            labelWith: 'Изображение: ${image?.filename}',
            labelWithout: 'Изображение не выбрано',
            onClear: () => setState(() => image = null),
            onPicked: () =>
                pickImage().then((value) => setState(() => image = value)),
          ),
          FileForm(
            file: mask,
            labelWith: 'Маска: ${mask?.filename}',
            labelWithout: 'Маска не выбрана',
            onClear: () => setState(() => mask = null),
            onPicked: () =>
                pickImage().then((value) => setState(() => mask = value)),
          ),
          ElevatedButton.icon(
            onPressed: image != null && mask != null
                ? () {
                    setState(() {
                      image = null;
                      mask = null;
                    });
                    widget.onSubmit(image!, mask!);
                  }
                : null,
            icon: Icon(Icons.file_upload),
            label: Text('Отправить на обработку'),
          )
        ],
      ),
    );
  }

  Future<MemoryFile> pickImage() async {
    final files = await controller!.pickFiles();
    final file = files.first; // files can be empty, but me need throw
    return await processBrowserFile(controller!, file);
  }
}

class FileForm extends StatelessWidget {
  final MemoryFile? file;
  final String labelWith;
  final String labelWithout;
  final void Function() onClear;
  final void Function() onPicked;

  FileForm(
      {required this.file,
      required this.labelWith,
      required this.labelWithout,
      required this.onClear,
      required this.onPicked});

  Widget build(BuildContext context) {
    return Row(
      children: (file == null)
          ? [
              Text(labelWithout),
              ElevatedButton(
                onPressed: onPicked,
                child: Text('Выбрать'),
              ),
            ]
          : [
              Text(labelWithout),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: onClear,
              )
            ],
    );
  }
}

Future<MemoryFile> processBrowserFile(
    DropzoneViewController controller, dynamic jsFile) async {
  final data = await Future.wait([
    controller.getFilename(jsFile),
    controller.getFileData(jsFile),
    controller.getFileMIME(jsFile),
  ]);
  final file = MemoryFile(
      filename: data[0] as String,
      data: data[1] as Uint8List,
      mime: data[2] as String);
  return file;
}
