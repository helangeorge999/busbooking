import 'package:hive_flutter/hive_flutter.dart';

/// Central Hive service for offline caching
class HiveService {
  static const String _bookingsBox = 'bookings_cache';
  static const String _profileBox = 'profile_cache';
  static const String _busesBox = 'buses_cache';

  /// Initialize Hive — call once in main()
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_bookingsBox);
    await Hive.openBox<Map>(_profileBox);
    await Hive.openBox<Map>(_busesBox);
  }

  // ── Bookings Cache ─────────────────────────────────────────────────────────

  static Box<Map> get _bookings => Hive.box<Map>(_bookingsBox);

  /// Save booking list to cache
  static Future<void> cacheBookings(List<Map<String, dynamic>> bookings) async {
    await _bookings.clear();
    for (int i = 0; i < bookings.length; i++) {
      await _bookings.put('booking_$i', Map<String, dynamic>.from(bookings[i]));
    }
    await _bookings.put('_meta', {
      'count': bookings.length,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached bookings
  static List<Map<String, dynamic>> getCachedBookings() {
    final meta = _bookings.get('_meta');
    if (meta == null) return [];

    final count = meta['count'] as int? ?? 0;
    final list = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      final item = _bookings.get('booking_$i');
      if (item != null) {
        list.add(_deepCastMap(item));
      }
    }
    return list;
  }

  /// Check if bookings cache exists
  static bool hasBookingsCache() {
    return _bookings.get('_meta') != null;
  }

  /// Get when bookings were last cached
  static String? getBookingsCacheTime() {
    final meta = _bookings.get('_meta');
    return meta?['cachedAt'] as String?;
  }

  // ── Profile Cache ──────────────────────────────────────────────────────────

  static Box<Map> get _profile => Hive.box<Map>(_profileBox);

  /// Save profile to cache
  static Future<void> cacheProfile(Map<String, dynamic> profile) async {
    await _profile.put('user_profile', Map<String, dynamic>.from(profile));
    await _profile.put('_meta', {'cachedAt': DateTime.now().toIso8601String()});
  }

  /// Get cached profile
  static Map<String, dynamic>? getCachedProfile() {
    final data = _profile.get('user_profile');
    if (data == null) return null;
    return _deepCastMap(data);
  }

  // ── Buses Cache ────────────────────────────────────────────────────────────

  static Box<Map> get _buses => Hive.box<Map>(_busesBox);

  /// Save bus search results to cache (keyed by route)
  static Future<void> cacheBuses(
    String from,
    String to,
    List<Map<String, dynamic>> buses,
  ) async {
    final key = '${from}_$to'.toLowerCase();
    final data = {
      'buses': buses.map((b) => Map<String, dynamic>.from(b)).toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    };
    await _buses.put(key, Map<String, dynamic>.from(data));
  }

  /// Get cached buses for a route
  static List<Map<String, dynamic>>? getCachedBuses(String from, String to) {
    final key = '${from}_$to'.toLowerCase();
    final data = _buses.get(key);
    if (data == null) return null;

    final cachedAt = DateTime.tryParse(data['cachedAt'] ?? '');
    // Cache expires after 1 hour
    if (cachedAt != null && DateTime.now().difference(cachedAt).inHours >= 1) {
      _buses.delete(key);
      return null;
    }

    final busList = data['buses'] as List?;
    if (busList == null) return null;
    return busList.map((b) => _deepCastMap(b as Map)).toList();
  }

  // ── Clear All Cache ────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _bookings.clear();
    await _profile.clear();
    await _buses.clear();
  }

  /// Clear only bookings cache
  static Future<void> clearBookings() async {
    await _bookings.clear();
  }

  // ── Helper: Deep cast Hive Map to Map<String, dynamic> ─────────────────────

  static Map<String, dynamic> _deepCastMap(Map map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _deepCastMap(value));
      } else if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e is Map ? _deepCastMap(e) : e).toList(),
        );
      }
      return MapEntry(key.toString(), value);
    });
  }
}
