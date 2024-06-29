import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_jet/send_message/view/send_message_view.dart';

import '../view_model/send_message_view_model.dart';
import 'image_preview.dart';

class CameraPreViewScreen extends StatefulWidget {
  const CameraPreViewScreen({Key? key, required this.camera}) : super(key: key);
  final List<CameraDescription>? camera;

  @override
  State<CameraPreViewScreen> createState() => _CameraPreViewScreenState();
}

class _CameraPreViewScreenState extends State<CameraPreViewScreen> {
  late CameraController _controller;
  late Future<void>? _initializeControllerFuture;
  bool _isRearCameraSelected = true;
  String base64ImageCamera = '';
  String? fileType;
  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    _controller = CameraController(cameraDescription, ResolutionPreset.high);
// Next, initialize the controller. This returns a Future.
    try {
      await _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    final provider = Provider.of<SendMessageViewModel>(context, listen: false);
    if (!_controller.value.isInitialized) {
      return null;
    }
    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      await _controller.setFlashMode(FlashMode.off);
      XFile picture = await _controller.takePicture();
      File cameraFile = File(picture.path);
      if (!mounted) return;
      if (picture != null) {
        fileType = "IMAGE";

        File? compressedImageFile =
            await provider.compressImage(File(cameraFile.path));
        if (compressedImageFile != null) {
          Uint8List? compressedImageBytes =
              await compressedImageFile.readAsBytesSync();
          // Convert the image to base64
          base64ImageCamera = base64Encode(compressedImageBytes);
        }
      }
      // ignore: use_build_context_synchronously
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PreviewPage(
      //               picture: picture,
      //               base64ImageCamera: base64ImageCamera,
      //               fileType: fileType.toString(),
      //             )));
    } catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.camera![0]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _controller.value.isInitialized
                ? CameraPreview(_controller)
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      color: Colors.black),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          icon: Icon(
                              _isRearCameraSelected
                                  ? CupertinoIcons.switch_camera
                                  : CupertinoIcons.switch_camera_solid,
                              color: Colors.white),
                          onPressed: () {
                            setState(() =>
                                _isRearCameraSelected = !_isRearCameraSelected);
                            initCamera(
                                widget.camera![_isRearCameraSelected ? 0 : 1]);
                          },
                        )),
                        Expanded(
                            child: IconButton(
                          onPressed: takePicture,
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.circle, color: Colors.white),
                        )),
                        const Spacer(),
                      ]),
                )),
          ],
        ),
      ),
    );
  }
}
