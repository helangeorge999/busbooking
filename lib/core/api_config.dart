import 'dart:io';

class ApiConfig {
  // ✅ CHANGE THIS to your PC's IPv4 address (run `ipconfig` in terminal)
  static const String _physicalDeviceIp = '192.168.18.113';

  // Emulator uses 10.0.2.2 to reach host machine's localhost
  static const String _emulatorIp = '10.0.2.2';

  static const int port = 5050;

  static bool? _isEmulator;

  /// Detect if running on emulator or physical device
  static Future<void> init() async {
    // Android emulators have known fingerprints
    // This is a simple heuristic that works for most cases
    try {
      _isEmulator = Platform.isAndroid && (await _checkEmulator());
    } catch (_) {
      _isEmulator = false;
    }
  }

  static Future<bool> _checkEmulator() async {
    try {
      // Emulator's host loopback is reachable at 10.0.2.2
      final result = await InternetAddress.lookup(
        '10.0.2.2',
      ).timeout(const Duration(seconds: 1));
      // If 10.0.2.2 resolves, we're likely on an emulator
      // But let's also try connecting to confirm
      try {
        final socket = await Socket.connect(
          '10.0.2.2',
          port,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
        return true; // Successfully connected via emulator IP
      } catch (_) {
        return false; // Can't connect, probably physical device
      }
    } catch (_) {
      return false;
    }
  }

  static bool get isEmulator => _isEmulator ?? true;

  static String get baseUrl {
    final ip = isEmulator ? _emulatorIp : _physicalDeviceIp;
    return 'http://$ip:$port';
  }

  static String get apiUrl => '$baseUrl/api';

  // Convenience getters for each API group
  static String get authUrl => '$apiUrl/auth';
  static String get userUrl => '$apiUrl/user';
  static String get adminUrl => '$apiUrl/admin';
  static String get busUrl => '$apiUrl/buses';
  static String get bookingUrl => '$apiUrl/bookings';

  /// Convert a localhost URL from backend to the correct device URL
  static String fixImageUrl(String url) {
    if (url.isEmpty) return url;
    return url
        .replaceFirst('http://localhost:$port', baseUrl)
        .replaceFirst('http://10.0.2.2:$port', baseUrl)
        .replaceFirst('http://$_physicalDeviceIp:$port', baseUrl);
  }
}
