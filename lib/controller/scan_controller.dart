import 'dart:math';
import 'package:image/image.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
// import 'package:tflite/tflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFlite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  late CameraImage cameraImage;

  var isCameraInitialised = false.obs;
  var cameraCount = 0;

  var x, y, w, h = 0.0;
  var label = "";

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      try {
        cameras = await availableCameras();

        if (cameras.isNotEmpty) {
          cameraController = CameraController(
            cameras[0],
            ResolutionPreset.max,
          );

          await cameraController.initialize().then((value) {
            cameraController.startImageStream((image) {
              cameraCount++;
              if (cameraCount % 10 == 0) {
                cameraCount = 0;
                objectDetector(image);
                // update();
              }
              update();
            });
          });
          isCameraInitialised(true);
          update();
        } else {
          print("No cameras available");
        }
      } catch (e) {
        print("Error initializing camera: $e");
      }
    } else {
      print("Permsission Denied");
    }
  }

  initTFlite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/label.text",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) {
        return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if (detector != null) {
      var ourDetectedObject = detector.first;
      if (ourDetectedObject['confidenceInClass'] * 100 > 45) {
        label = detector.first['detectedClass'].toString();
        h = ourDetectedObject['rect']['h'];
        w = ourDetectedObject['rect']['w'];
        x = ourDetectedObject['rect']['x'];
        y = ourDetectedObject['rect']['y'];
      }
      update();
      // print('Result is $detector');
    }
  }
}
