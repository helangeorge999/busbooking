import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _optionalContactController = TextEditingController();
  String _selectedBoardingPoint = 'Kathmandu';

  final List<String> _boardingPoints = [
    'Kathmandu',
    'Bhaktapur',
    'Lalitpur',
    'Banepa',
    'Dhulikhel',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _optionalContactController.dispose();
    super.dispose();
  }

  /// Generate a simple booking ID
  String _generateBookingId() {
    final now = DateTime.now();
    return 'BK${now.millisecondsSinceEpoch.toString().substring(6)}';
  }

  /// Today's date formatted
  String get _todayFormatted {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      final booking = BookingData(
        bus: widget.bus,
        selectedSeats: widget.selectedSeats,
        passengerName: _fullNameController.text.trim(),
        contact: _contactController.text.trim(),
        boardingPoint: _selectedBoardingPoint,
        bookingId: _generateBookingId(),
        bookingDate: _todayFormatted,
      );

      // Navigate to Ticket Screen — replacing this page so back won't return here
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.bus.price * widget.selectedSeats.length;

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
              // ── Trip summary card ──────────────────────────────────
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.bus.type,
                            style: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      'Route',
                      '${widget.bus.from} → ${widget.bus.to}',
                    ),
                    _detailRow(
                      'Departure',
                      '${widget.bus.departure} → ${widget.bus.arrival}',
                    ),
                    _detailRow('Seat(s)', widget.selectedSeats.join(', ')),
                    _detailRow('Passengers', '${widget.selectedSeats.length}'),
                    _detailRow('Date', _todayFormatted),
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
                          'Rs. ${totalPrice.toInt()}',
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

              // ── Boarding Point ─────────────────────────────────────
              const Text(
                'Boarding Point',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedBoardingPoint,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                items: _boardingPoints
                    .map(
                      (point) =>
                          DropdownMenuItem(value: point, child: Text(point)),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedBoardingPoint = val!),
              ),

              const SizedBox(height: 14),

              // ── Full Name ──────────────────────────────────────────
              const Text(
                'Full Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),

              const SizedBox(height: 14),

              // ── Contact Number ─────────────────────────────────────
              const Text(
                'Contact Number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Passenger's number",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                validator: (val) => (val == null || val.trim().length < 10)
                    ? 'Enter a valid phone number'
                    : null,
              ),

              const SizedBox(height: 14),

              // ── Optional Number ────────────────────────────────────
              const Text(
                'Optional Number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _optionalContactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Second number (Optional)',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Confirm button ─────────────────────────────────────
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
                  onPressed: _submitBooking,
                  child: const Text(
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
