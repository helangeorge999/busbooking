import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_config.dart';
import 'bus_list_screen.dart';
import 'ticket_screen.dart';

class PassengerDetailScreen extends StatefulWidget {
  final BusModel bus;
  final List<String> selectedSeats;

  const PassengerDetailScreen({
    super.key,
    required this.bus,
    required this.selectedSeats,
  });

  @override
  State<PassengerDetailScreen> createState() => _PassengerDetailScreenState();
}

class _PassengerDetailScreenState extends State<PassengerDetailScreen> {
  static String get _bookingUrl => ApiConfig.bookingUrl;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String get _todayFormatted {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  double get _totalAmount => widget.bus.price * widget.selectedSeats.length;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        _showSnack('Session expired. Please login again.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // ✅ FIX: Use widget.bus.id (MongoDB _id), NOT widget.bus.to
      final body = jsonEncode({
        'busId': widget.bus.id,
        'from': widget.bus.from,
        'to': widget.bus.to,
        'travelDate': _todayFormatted,
        'seats': widget.selectedSeats.join(', '),
        'totalAmount': _totalAmount,
        'passengerName': _nameCtrl.text.trim(),
        'passengerPhone': _phoneCtrl.text.trim(),
        'passengerEmail': _emailCtrl.text.trim(),
      });

      final response = await http
          .post(
            Uri.parse(_bookingUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        final booking = data['data'] as Map<String, dynamic>;

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TicketScreen(
              booking: BookingData(
                bus: widget.bus,
                selectedSeats: widget.selectedSeats,
                passengerName: _nameCtrl.text.trim(),
                contact: _phoneCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                boardingPoint: widget.bus.from,
                bookingId:
                    booking['bookingId'] ??
                    'BK${DateTime.now().millisecondsSinceEpoch}',
                bookingDate: _todayFormatted,
              ),
            ),
          ),
        );
      } else {
        _showSnack(data['message'] ?? 'Booking failed. Try again.', Colors.red);
      }
    } catch (e) {
      _showSnack('Network error. Check your connection.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Passenger Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Trip Summary Card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          color: Color(0xFF1565C0),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.bus.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        _typeBadge(widget.bus.type),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _row('Route', '${widget.bus.from} → ${widget.bus.to}'),
                    _row(
                      'Departure',
                      '${widget.bus.departure} → ${widget.bus.arrival}',
                    ),
                    _row('Seat(s)', widget.selectedSeats.join(', ')),
                    _row('Passengers', '${widget.selectedSeats.length}'),
                    _row('Travel Date', _todayFormatted),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs. ${_totalAmount.toInt()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              const Text(
                "Passenger's Detail",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              _label('Full Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDeco(
                  hint: 'Enter full name',
                  icon: Icons.person_outline,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),

              const SizedBox(height: 14),

              _label('Contact Number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco(
                  hint: "Passenger's phone number",
                  icon: Icons.phone_outlined,
                ),
                validator: (v) => (v == null || v.trim().length < 7)
                    ? 'Enter a valid phone number'
                    : null,
              ),

              const SizedBox(height: 14),

              _label('Email Address'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco(
                  hint: "Passenger's email",
                  icon: Icons.email_outlined,
                ),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitBooking,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeBadge(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF1565C0).withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      type,
      style: const TextStyle(
        color: Color(0xFF1565C0),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  );

  InputDecoration _inputDeco({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      );
}
