import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final ImageProvider imageProvider;
  final Decoration backgroundDecoration;

  const ImagePreview(
      {required this.imageProvider, required this.backgroundDecoration});

  Widget build(BuildContext context) {
    return Image(image: imageProvider);
  }
}
