import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── AdminBookingsScreen ───────────────────────────────────────────────────────
// GET   /api/bookings              → all bookings (admin only)
//   Response: { success, data: IBooking[] } — userId & busId populated
// PATCH /api/bookings/:id/cancel   → cancel a booking
class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  static const String _base = 'http://10.0.2.2:5050/api/bookings';

  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all'; // all | confirmed | cancelled

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<Map<String, String>> _headers() async {
    final p = await SharedPreferences.getInstance();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${p.getString('token') ?? ''}',
    };
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(Uri.parse(_base), headers: await _headers());
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        final list = (body['data'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _all = list;
          _applyFilter(_filter);
          _loading = false;
        });
      } else {
        setState(() {
          _error = body['message'];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Network error';
        _loading = false;
      });
    }
  }

  void _applyFilter(String f) {
    _filter = f;
    if (f == 'all') {
      _filtered = List.from(_all);
    } else {
      _filtered = _all.where((b) => b['status'] == f).toList();
    }
  }

  Future<void> _cancel(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Cancel Booking'),
        content: const Text(
          'Cancel this booking? The status will be updated to cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await http.patch(
        Uri.parse('$_base/$id/cancel'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        _snack('Booking cancelled', Colors.orange);
        _fetch();
      } else {
        _snack(body['message'] ?? 'Failed', Colors.red);
      }
    } catch (_) {
      _snack('Network error', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0)),
      );
    }

    return Column(
      children: [
        // ── Filter chips ───────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _chip('All', 'all'),
              const SizedBox(width: 8),
              _chip('Confirmed', 'confirmed'),
              const SizedBox(width: 8),
              _chip('Cancelled', 'cancelled'),
            ],
          ),
        ),

        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: _error != null
              ? _errorView()
              : _filtered.isEmpty
              ? _emptyView()
              : RefreshIndicator(
                  onRefresh: _fetch,
                  color: const Color(0xFF1565C0),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) =>
                        _BookingTile(booking: _filtered[i], onCancel: _cancel),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _applyFilter(value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1565C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF1565C0) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _errorView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _fetch,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
          ),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          'No ${_filter == 'all' ? '' : _filter} bookings',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

// ── Booking Tile ──────────────────────────────────────────────────────────────
class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Future<void> Function(String id) onCancel;

  const _BookingTile({required this.booking, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final String id = booking['_id'] ?? '';
    final String bookingId = booking['bookingId'] ?? '';
    final String from = booking['from'] ?? '';
    final String to = booking['to'] ?? '';
    final String travelDate = booking['travelDate'] ?? '';
    final String seats = booking['seats'] ?? '';
    final num amount = booking['totalAmount'] ?? 0;
    final String pName = booking['passengerName'] ?? '';
    final String pPhone = booking['passengerPhone'] ?? '';
    final String pEmail = booking['passengerEmail'] ?? '';
    final String status = booking['status'] ?? 'confirmed';

    // userId populated: { name, email }
    final user = booking['userId'] as Map<String, dynamic>?;
    final String userName = user?['name'] ?? '';
    final String userEmail = user?['email'] ?? '';

    // busId populated
    final bus = booking['busId'] as Map<String, dynamic>?;
    final String busName = bus?['name'] ?? 'Bus';

    final bool isConfirmed = status == 'confirmed';
    final Color statusColor = isConfirmed ? Colors.green : Colors.red;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    busName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _badge(status.toUpperCase(), statusColor),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$bookingId  •  $from → $to',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Booking info grid
            _row('Travel Date', travelDate),
            _row('Seats', seats),
            _row('Passenger', pName),
            _row('Passenger Phone', pPhone),
            _row('Passenger Email', pEmail),
            _row('Booked By', '$userName ($userEmail)'),
            _row('Total Amount', 'Rs. ${amount.toInt()}'),

            // Cancel button — only for confirmed
            if (isConfirmed) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 16,
                  ),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  onPressed: () => onCancel(id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
