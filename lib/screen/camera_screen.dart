import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:object_detect/controller/scan_controller.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialised.value
                ? Stack(children: [
                    CameraPreview(controller.cameraController),
                    Positioned(
                      top: (controller.y) * 700,
                      right: (controller.x) * 500,
                      child: Container(
                        width: controller.w * 100 * context.width / 100,
                        height: controller.h * 100 * context.height / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green,
                            width: 4.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                color: Colors.white,
                                child: Text(controller.label)),
                          ],
                        ),
                      ),
                    )
                  ])
                : const Center(child: Text("Loading Preview..."));
          }),
    );
  }
}
