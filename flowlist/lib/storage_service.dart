import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();
}
