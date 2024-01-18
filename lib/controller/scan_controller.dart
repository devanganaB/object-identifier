import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialised = false.obs;

  initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[0],
          ResolutionPreset.max,
        );

        await cameraController.initialize();
        isCameraInitialised(true);
        update();
      } else {
        print("No cameras available");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }
}
