import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
export 'package:permission_handler/permission_handler.dart';

import '../services/internal/imkit_core.dart';

Future<bool> zegoIMKitRequestPermission(Permission permission) async {
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    return true;
  }
  var status = await permission.request();
  if (status != PermissionStatus.granted) {
    ZegoIMKitLogger.severe('Error: ${permission.toString()} permission not granted, $status');
    return false;
  }

  return true;
}
