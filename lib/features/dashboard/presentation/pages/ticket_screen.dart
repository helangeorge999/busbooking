import 'package:flutter/material.dart';
import 'bus_list_screen.dart';
import '../../../auth/presentation/pages/main_shell.dart';

class BookingData {
  final BusModel bus;
  final List<String> selectedSeats;
  final String passengerName;
  final String contact;
  final String email;
  final String boardingPoint;
  final String bookingId;
  final String bookingDate;

  BookingData({
    required this.bus,
    required this.selectedSeats,
    required this.passengerName,
    required this.contact,
    this.email = '',
    required this.boardingPoint,
    required this.bookingId,
    required this.bookingDate,
  });
}

class TicketScreen extends StatelessWidget {
  final BookingData booking;

  const TicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final totalPrice = booking.bus.price * booking.selectedSeats.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 52),
                  SizedBox(height: 8),
                  Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your seat has been reserved successfully',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 28,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking.bus.type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          booking.bus.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              booking.bus.from,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                            Text(
                              booking.bus.to,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _DashedDivider(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _timeBlock(
                              label: 'Departure',
                              time: booking.bus.departure,
                              city: booking.bus.from,
                            ),
                            Column(
                              children: [
                                Text(
                                  booking.bus.duration,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1565C0),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    const Icon(
                                      Icons.directions_bus,
                                      size: 16,
                                      color: Color(0xFF1565C0),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1565C0),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            _timeBlock(
                              label: 'Arrival',
                              time: booking.bus.arrival,
                              city: booking.bus.to,
                              alignRight: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 12),

                        _twoColRow(
                          left: _detailItem(
                            Icons.event_seat_outlined,
                            'Seat(s)',
                            booking.selectedSeats.join(', '),
                          ),
                          right: _detailItem(
                            Icons.people_outline,
                            'Passengers',
                            '${booking.selectedSeats.length}',
                          ),
                        ),
                        const SizedBox(height: 14),
                        _twoColRow(
                          left: _detailItem(
                            Icons.location_on_outlined,
                            'Boarding',
                            booking.boardingPoint,
                          ),
                          right: _detailItem(
                            Icons.calendar_today_outlined,
                            'Date',
                            booking.bookingDate,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _twoColRow(
                          left: _detailItem(
                            Icons.person_outline,
                            'Passenger',
                            booking.passengerName,
                          ),
                          right: _detailItem(
                            Icons.phone_outlined,
                            'Contact',
                            booking.contact,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Booking ID',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              booking.bookingId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _DashedDivider(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs. ${totalPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Go to Home button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.home_outlined, color: Colors.white),
                label: const Text(
                  'Go to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  print('🏠 Go to Home pressed');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) {
                      print('🗺️ Removing route: $route');
                      return false;
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Book another ticket ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1565C0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF1565C0),
                ),
                label: const Text(
                  'Book Another Ticket',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 4);
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _timeBlock({
    required String label,
    required String time,
    required String city,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          time,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        Text(city, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _twoColRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final count = (constraints.maxWidth / (dashWidth + dashSpace))
                  .floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  count,
                  (_) => Container(
                    width: dashWidth,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
      ],
    );
  }
}
