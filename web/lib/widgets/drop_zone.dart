import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_dropzone/flutter_dropzone.dart';

typedef DropBuilder = Function(BuildContext context, DropState state);

enum DropState { hover, drop, none }

class DropZone extends StatefulWidget {
  final DropBuilder builder;

  DropZone({required this.builder});

  @override
  State<StatefulWidget> createState() => _StateDropZone();
}

class _StateDropZone extends State<DropZone> {
  late DropzoneViewController controller;
  DropState dropState = DropState.none;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
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
          onDrop: (ev) {
            print('Drop: $ev');
            setState(() {
              dropState = DropState.none;
            });
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
