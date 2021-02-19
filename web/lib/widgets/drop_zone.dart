import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:web/memory_file.dart';

typedef DropBuilder = Widget Function(BuildContext context, DropState state);
typedef OnFile = void Function(MemoryFile memoryFile);

enum DropState { hover, drop, none }

class DropZone extends StatefulWidget {
  final DropBuilder builder;
  final OnFile onFile;

  DropZone({required this.builder, required this.onFile});

  @override
  State<StatefulWidget> createState() => _StateDropZone();
}

class _StateDropZone extends State<DropZone> {
  late DropzoneViewController controller;
  DropState dropState = DropState.none;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      children: [
        DropzoneView(
          operation: DragOperation.copy,
          cursor: CursorType.auto,
          onCreated: (ctrl) => controller = ctrl,
          onLoaded: () => print('Zone loaded'),
          onError: (ev) => print('Error: $ev'),
          onHover: () {
            setState(() {
              dropState = DropState.hover;
            });
            print('Zone hovered');
          },
          onDrop: (ev) async {
            print('Drop: $ev');
            setState(() {
              dropState = DropState.none;
            });
            try {
              final data = await Future.wait([
                controller.getFilename(ev),
                controller.getFileData(ev),
                controller.getFileMIME(ev),
              ]);
              final file = MemoryFile(
                  filename: data[0] as String,
                  data: data[1] as Uint8List,
                  mime: data[2] as String);
              widget.onFile(file);
            } catch (e) {
              // none
            }
          },
          onLeave: () {
            setState(() {
              dropState = DropState.none;
            });
            print('Zone leave');
          },
        ),
        widget.builder(context, dropState),
      ],
    );
  }
}
