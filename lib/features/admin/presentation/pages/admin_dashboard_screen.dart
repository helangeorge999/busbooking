import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const String _base = 'http://10.0.2.2:5050/api';

  bool _loading = true;
  int _totalBuses = 0;
  int _totalBookings = 0;
  int _confirmedBookings = 0;
  int _cancelledBookings = 0;
  int _totalUsers = 0;
  double _totalRevenue = 0;
  List<Map<String, dynamic>> _recentBookings = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<String> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('token') ?? '';
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final token = await _token();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Fetch in parallel
      final results = await Future.wait([
        http.get(Uri.parse('$_base/buses'), headers: headers),
        http.get(Uri.parse('$_base/bookings'), headers: headers),
        http.get(Uri.parse('$_base/admin/users'), headers: headers),
      ]);

      // Buses — GET /api/buses → { success, data: IBus[] }
      final busBody = jsonDecode(results[0].body);
      final busList = (busBody['data'] as List?) ?? [];

      // Bookings — GET /api/bookings → { success, data: IBooking[] }
      final bookBody = jsonDecode(results[1].body);
      final bookList = (bookBody['data'] as List?) ?? [];

      // Users — GET /api/admin/users → { success, data: IUser[] }
      final userBody = jsonDecode(results[2].body);
      final userList = (userBody['data'] as List?) ?? [];

      final confirmed = bookList
          .where((b) => b['status'] == 'confirmed')
          .toList();
      final cancelled = bookList
          .where((b) => b['status'] == 'cancelled')
          .toList();
      final revenue = confirmed.fold<double>(
        0,
        (sum, b) => sum + ((b['totalAmount'] ?? 0) as num).toDouble(),
      );

      // Recent 5 bookings
      final recent = bookList.reversed
          .take(5)
          .toList()
          .cast<Map<String, dynamic>>();

      setState(() {
        _totalBuses = busList.length;
        _totalBookings = bookList.length;
        _confirmedBookings = confirmed.length;
        _cancelledBookings = cancelled.length;
        _totalUsers = userList.length;
        _totalRevenue = revenue;
        _recentBookings = recent;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: const Color(0xFF1565C0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Banner ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Overview',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bus Booking System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total Revenue: Rs. ${_totalRevenue.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ── Stats Grid ────────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _statCard(
                  'Total Buses',
                  '$_totalBuses',
                  Icons.directions_bus,
                  Colors.blue,
                ),
                _statCard(
                  'Total Users',
                  '$_totalUsers',
                  Icons.people,
                  Colors.teal,
                ),
                _statCard(
                  'Confirmed',
                  '$_confirmedBookings',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _statCard(
                  'Cancelled',
                  '$_cancelledBookings',
                  Icons.cancel_outlined,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Total Bookings banner ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Bookings',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '$_totalBookings',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Recent Bookings ───────────────────────────────────────
            const Text(
              'Recent Bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_recentBookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._recentBookings.map((b) => _recentBookingTile(b)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentBookingTile(Map<String, dynamic> b) {
    final String bookingId = b['bookingId'] ?? '';
    final String from = b['from'] ?? '';
    final String to = b['to'] ?? '';
    final String passengerName = b['passengerName'] ?? '';
    final num amount = b['totalAmount'] ?? 0;
    final String status = b['status'] ?? 'confirmed';
    final Color statusColor = status == 'confirmed' ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFF1565C0),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passengerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$from → $to  •  $bookingId',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${amount.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1565C0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
