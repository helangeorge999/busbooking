import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Providers/booking_provider.dart';
import 'ticket_confirmation_screen.dart';

class BookingDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);

    // Convert selected seat numbers to indices (for TicketConfirmationScreen)
    final seatIndices = booking.seatNumber.split(', ').map((seat) {
      if (seat.startsWith('A')) return int.parse(seat.substring(1)) - 1;
      if (seat.startsWith('B')) return int.parse(seat.substring(1)) + 19;
      if (seat.startsWith('C')) return int.parse(seat.substring(1)) + 39;
      return 0;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bus Name: ${booking.busName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('From: ${booking.from}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('To: ${booking.to}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Date: ${booking.date}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Seats: ${booking.seatNumber}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to TicketConfirmationScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketConfirmationScreen(
                        seats: seatIndices,
                        passengerName: '',
                        from: '',
                        to: '',
                        busName: '',
                        seatNumber: '',
                      ),
                    ),
                  );
                },
                child: Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
