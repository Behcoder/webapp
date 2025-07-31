import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    // بررسی اولیه اتصال
    await _checkConnectivity();
    
    // گوش دادن به تغییرات اتصال
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isConnected = results.any((result) => result != ConnectivityResult.none);
      _connectivityController.add(_isConnected);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _isConnected = connectivityResult.any((result) => result != ConnectivityResult.none);
      _connectivityController.add(_isConnected);
    } catch (e) {
      _isConnected = false;
      _connectivityController.add(false);
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _isConnected = connectivityResult.any((result) => result != ConnectivityResult.none);
      _connectivityController.add(_isConnected);
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _connectivityController.add(false);
      return false;
    }
  }

  void dispose() {
    _connectivityController.close();
  }
} 