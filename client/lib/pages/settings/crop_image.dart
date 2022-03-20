import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop/crop.dart';
import 'package:solidtrade/components/base/st_widget.dart';

class CropImageScreen extends StatefulWidget {
  const CropImageScreen({Key? key, required this.bytes}) : super(key: key);
  final Uint8List bytes;

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> with STWidget {
  final controller = CropController(aspectRatio: 1 / 1);
  void _handleClickDiscard() {
    Navigator.pop(context);
  }

  void _handleClickSaveCroppedImage(ui.Image cropped) {
    Navigator.of(context).pop(cropped);
    Navigator.of(context).pop(cropped);
  }

  void _handleClickSave() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cropped = await controller.crop(pixelRatio: pixelRatio);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text('Crop Result'),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Center(
                child: RawImage(
                  image: cropped,
                ),
              ),
              const SizedBox(height: 35),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Go back")),
                  const SizedBox(width: 20),
                  ElevatedButton(onPressed: () => _handleClickSaveCroppedImage(cropped), child: const Text("Crop")),
                ],
              )
            ],
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Crop(
              backgroundColor: colors.background,
              controller: controller,
              shape: BoxShape.rectangle,
              child: Image.memory(widget.bytes, width: 100, height: 100),
              helper: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.blueBackground, width: 2),
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            color: colors.foreground,
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                    tooltip: 'Reset',
                    onPressed: () {
                      setState(() {
                        controller.rotation = 0;
                        controller.scale = 1;
                        controller.offset = Offset.zero;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Slider(
                    divisions: 200,
                    value: controller.scale,
                    min: 1,
                    max: 10,
                    onChanged: (n) {
                      setState(() {
                        controller.scale = n;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 50),
                TextButton(onPressed: _handleClickDiscard, child: const Text("Discard", style: TextStyle(color: Colors.red))),
                const SizedBox(width: 30),
                TextButton(onPressed: _handleClickSave, child: const Text("Save", style: TextStyle(color: Colors.green))),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
