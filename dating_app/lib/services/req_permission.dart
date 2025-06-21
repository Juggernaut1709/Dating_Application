import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as dev;

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;

  if (status.isDenied) {
    status = await Permission.location.request();
  }

  if (status.isGranted) {
    dev.log("Location permission granted.");
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  } else {
    dev.log("Location permission denied.");
  }
}
