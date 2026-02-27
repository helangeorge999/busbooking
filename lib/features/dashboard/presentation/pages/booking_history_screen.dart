import 'dart:convert';
import 'package:busbooking/core/services/hive/hive_service.dart'; // ✅ single correct import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_config.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isOffline = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http
          .get(
            Uri.parse('${ApiConfig.bookingUrl}/my-bookings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final List<dynamic> list = body['data'] ?? [];
        final bookings = list.cast<Map<String, dynamic>>();

        await HiveService.cacheBookings(bookings);

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        _loadFromCache(body['message'] ?? 'Failed to load bookings');
      }
    } catch (e) {
      _loadFromCache('No internet connection');
    }
  }

  void _loadFromCache(String originalError) {
    if (HiveService.hasBookingsCache()) {
      final cached = HiveService.getCachedBookings();
      setState(() {
        _bookings = cached;
        _isLoading = false;
        _isOffline = true;
      });
    } else {
      setState(() {
        _error = originalError;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(String mongoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.patch(
        Uri.parse('${ApiConfig.bookingUrl}/$mongoId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        _fetchBookings();
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Failed to cancel'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey[100], child: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _fetchBookings,
              ),
            ],
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booked tickets will appear here.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange[100],
            child: Row(
              children: [
                const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing cached data (offline)',
                    style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                  ),
                ),
                GestureDetector(
                  onTap: _fetchBookings,
                  child: Icon(
                    Icons.refresh,
                    size: 18,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF1565C0),
            onRefresh: _fetchBookings,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bookings.length,
              itemBuilder: (_, i) => _BookingCard(
                booking: _bookings[i],
                onCancel: _cancelBooking,
                isOffline: _isOffline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final void Function(String mongoId) onCancel;
  final bool isOffline;

  const _BookingCard({
    required this.booking,
    required this.onCancel,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final String bookingId = booking['bookingId'] ?? '';
    final String from = booking['from'] ?? '';
    final String to = booking['to'] ?? '';
    final String travelDate = booking['travelDate'] ?? '';
    final String seats = booking['seats'] ?? '';
    final num totalAmount = booking['totalAmount'] ?? 0;
    final String passengerName = booking['passengerName'] ?? '';
    final String passengerPhone = booking['passengerPhone'] ?? '';
    final String status = booking['status'] ?? 'confirmed';
    final String mongoId = booking['_id'] ?? '';

    final bus = booking['busId'] as Map<String, dynamic>?;
    final String busName = bus?['name'] ?? 'Bus';
    final String departureTime = bus?['departureTime'] ?? '';
    final String arrivalTime = bus?['arrivalTime'] ?? '';
    final String busType = bus?['type'] ?? '';

    final bool isConfirmed = status == 'confirmed';
    final Color statusColor = isConfirmed ? Colors.green : Colors.red;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    busName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  busType,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  '• $bookingId',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        from,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        departureTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_right_alt, color: Color(0xFF1565C0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        to,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        arrivalTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            _detRow('Travel Date', travelDate),
            _detRow('Passenger', passengerName),
            _detRow('Phone', passengerPhone),
            _detRow('Seats', seats),
            _detRow('Total', 'Rs. ${totalAmount.toInt()}'),
            if (isConfirmed && !isOffline) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 16,
                  ),
                  label: const Text(
                    'Cancel Booking',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  onPressed: () => onCancel(mongoId),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
