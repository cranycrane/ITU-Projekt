/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Jakub Jerabek (xjerab28)

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

// Uložení ID zařízení
  Future<void> saveUserId(String userId) async {
    await storage.write(key: 'userId', value: userId);
  }

  // Načtení ID zařízení
  Future<String?> getUserId() async {
    return await storage.read(key: 'userId');
  }
}
