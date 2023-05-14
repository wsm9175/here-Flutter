import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceUniqueId() async {
  var deviceIdentifier = 'unknown';
  var deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;
    deviceIdentifier = androidInfo.androidId!;
  } else if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    deviceIdentifier = iosInfo.identifierForVendor!;
  }
  return deviceIdentifier;
}