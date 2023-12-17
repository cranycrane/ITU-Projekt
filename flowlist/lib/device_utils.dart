/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Jakub Jerabek (xjerab28)
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class DeviceUtils {
  static Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unikátní ID Android zařízení
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor; // Unikátní ID iOS zařízení
      } else {
        deviceId = null;
      }
    } catch (e) {
      deviceId = null;
      throw Exception("Couldnt get deviceId");
    }

    return deviceId;
  }
}
