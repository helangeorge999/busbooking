import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light_sensor/light_sensor.dart';
import '../../../../main.dart';
import '../../../../core/app_translations.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  // ── Accelerometer ──────────────────────────────────────────────────────────
  double _accelX = 0, _accelY = 0, _accelZ = 0;
  StreamSubscription? _accelSub;

  // ── Gyroscope ──────────────────────────────────────────────────────────────
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;
  StreamSubscription? _gyroSub;

  // ── Magnetometer ───────────────────────────────────────────────────────────
  double _magX = 0, _magY = 0, _magZ = 0;
  StreamSubscription? _magSub;

  // ── Light Sensor ───────────────────────────────────────────────────────────
  int _lux = 0;
  bool _hasLightSensor = false;
  StreamSubscription? _lightSub;
  Timer? _brightnessTimer;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  Future<void> _initSensors() async {
    // Accelerometer
    _accelSub = accelerometerEventStream().listen((e) {
      if (mounted)
        setState(() {
          _accelX = e.x;
          _accelY = e.y;
          _accelZ = e.z;
        });
    });

    // Gyroscope
    _gyroSub = gyroscopeEventStream().listen((e) {
      if (mounted)
        setState(() {
          _gyroX = e.x;
          _gyroY = e.y;
          _gyroZ = e.z;
        });
    });

    // Magnetometer
    _magSub = magnetometerEventStream().listen((e) {
      if (mounted)
        setState(() {
          _magX = e.x;
          _magY = e.y;
          _magZ = e.z;
        });
    });

    // Light Sensor
    try {
      final hasSensor = await LightSensor.hasSensor();
      setState(() => _hasLightSensor = hasSensor);
      if (hasSensor) {
        _lightSub = LightSensor.luxStream().listen((lux) {
          if (mounted) {
            setState(() => _lux = lux);
            // Auto brightness: debounce 2 s before switching theme
            if (appProvider.autoBrightness) {
              final needsDark =
                  lux < 20 && appProvider.themeModeName != 'dark';
              final needsLight =
                  lux > 100 && appProvider.themeModeName != 'light';
              if (needsDark || needsLight) {
                _brightnessTimer?.cancel();
                _brightnessTimer = Timer(const Duration(seconds: 2), () {
                  if (mounted && appProvider.autoBrightness) {
                    if (lux < 20) {
                      appProvider.setThemeMode('dark');
                    } else if (lux > 100) {
                      appProvider.setThemeMode('light');
                    }
                  }
                });
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Light sensor error: $e');
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magSub?.cancel();
    _lightSub?.cancel();
    _brightnessTimer?.cancel();
    super.dispose();
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  /// Compass heading in degrees (0–360) derived from magnetometer X/Y
  double get _compassDegrees {
    final angle = atan2(_magY, _magX) * 180 / pi;
    return (angle + 360) % 360;
  }

  String get _compassDirection {
    final d = _compassDegrees;
    if (d < 22.5 || d >= 337.5) return 'N';
    if (d < 67.5) return 'NE';
    if (d < 112.5) return 'E';
    if (d < 157.5) return 'SE';
    if (d < 202.5) return 'S';
    if (d < 247.5) return 'SW';
    if (d < 292.5) return 'W';
    return 'NW';
  }

  String get _lightLevel {
    if (_lux < 10) return 'Very Dark';
    if (_lux < 50) return 'Dark';
    if (_lux < 200) return 'Dim';
    if (_lux < 1000) return 'Normal';
    if (_lux < 10000) return 'Bright';
    return 'Very Bright';
  }

  Color get _lightColor {
    if (_lux < 10) return Colors.indigo;
    if (_lux < 50) return Colors.blueGrey;
    if (_lux < 200) return Colors.orange;
    if (_lux < 1000) return Colors.amber;
    return Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appProvider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sensors',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Accelerometer Card ───────────────────────────────────
            _SensorCard(
              cardColor: cardColor,
              icon: Icons.vibration,
              iconColor: Colors.orange,
              title: 'Accelerometer',
              subtitle: 'Measures device acceleration',
              child: Column(
                children: [
                  _SensorBar(
                    label: 'X',
                    value: _accelX,
                    maxVal: 20,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _SensorBar(
                    label: 'Y',
                    value: _accelY,
                    maxVal: 20,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _SensorBar(
                    label: 'Z',
                    value: _accelZ,
                    maxVal: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ValueChip('X: ${_fmt(_accelX)}', Colors.red),
                      _ValueChip('Y: ${_fmt(_accelY)}', Colors.green),
                      _ValueChip('Z: ${_fmt(_accelZ)}', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Gyroscope Card ───────────────────────────────────────
            _SensorCard(
              cardColor: cardColor,
              icon: Icons.screen_rotation,
              iconColor: Colors.purple,
              title: 'Gyroscope',
              subtitle: 'Measures device rotation',
              child: Column(
                children: [
                  _SensorBar(
                    label: 'X',
                    value: _gyroX,
                    maxVal: 10,
                    color: Colors.pink,
                  ),
                  const SizedBox(height: 8),
                  _SensorBar(
                    label: 'Y',
                    value: _gyroY,
                    maxVal: 10,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  _SensorBar(
                    label: 'Z',
                    value: _gyroZ,
                    maxVal: 10,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ValueChip('X: ${_fmt(_gyroX)}', Colors.pink),
                      _ValueChip('Y: ${_fmt(_gyroY)}', Colors.teal),
                      _ValueChip('Z: ${_fmt(_gyroZ)}', Colors.amber),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Magnetometer Card ────────────────────────────────────
            _SensorCard(
              cardColor: cardColor,
              icon: Icons.explore,
              iconColor: Colors.teal,
              title: 'Magnetometer',
              subtitle: 'Compass · heading: ${_compassDegrees.toStringAsFixed(1)}°',
              child: Column(
                children: [
                  // Compass dial
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.teal.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: _compassDegrees * pi / 180,
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.teal,
                              size: 48,
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            child: Text(
                              _compassDirection,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SensorBar(label: 'X', value: _magX, maxVal: 100, color: Colors.teal),
                  const SizedBox(height: 8),
                  _SensorBar(label: 'Y', value: _magY, maxVal: 100, color: Colors.cyan),
                  const SizedBox(height: 8),
                  _SensorBar(label: 'Z', value: _magZ, maxVal: 100, color: Colors.green),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ValueChip('X: ${_fmt(_magX)}', Colors.teal),
                      _ValueChip('Y: ${_fmt(_magY)}', Colors.cyan),
                      _ValueChip('Z: ${_fmt(_magZ)}', Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Light Sensor Card ────────────────────────────────────
            _SensorCard(
              cardColor: cardColor,
              icon: Icons.light_mode,
              iconColor: _lightColor,
              title: 'Light Sensor',
              subtitle: _hasLightSensor
                  ? 'Ambient light: $_lightLevel'
                  : 'Light sensor not available on this device',
              child: _hasLightSensor
                  ? Column(
                      children: [
                        // Lux display
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: _lightColor,
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$_lux',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: _lightColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LUX',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Light level bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: min(_lux / 1000, 1.0),
                            minHeight: 10,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(_lightColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Auto brightness toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.brightness_auto,
                                  color: _lightColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Auto Dark/Light Mode',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: appProvider.autoBrightness,
                              onChanged: (v) =>
                                  appProvider.toggleAutoBrightness(v),
                              activeColor: const Color(0xFF1565C0),
                            ),
                          ],
                        ),
                        if (appProvider.autoBrightness)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Dark mode activates below 20 lux, light mode above 100 lux',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sensors_off,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Not available on emulator.\nTry on a physical device.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sensor Card ──────────────────────────────────────────────────────────────
class _SensorCard extends StatelessWidget {
  final Color cardColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _SensorCard({
    required this.cardColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Sensor Value Bar ─────────────────────────────────────────────────────────
class _SensorBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxVal;
  final Color color;

  const _SensorBar({
    required this.label,
    required this.value,
    required this.maxVal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = (value.abs() / maxVal).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Value Chip ───────────────────────────────────────────────────────────────
class _ValueChip extends StatelessWidget {
  final String text;
  final Color color;

  const _ValueChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
