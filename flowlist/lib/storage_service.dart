import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

// Uložení ID zařízení
  Future<void> saveDeviceId(String? deviceId) async {
    await storage.write(key: 'deviceId', value: deviceId);
  }

  // Načtení ID zařízení
  Future<String?> getDeviceId() async {
    return await storage.read(key: 'deviceId');
  }
}
