import 'package:flutter/material.dart';
import 'home_screen.dart';

class TicketConfirmationScreen extends StatelessWidget {
  final String passengerName;
  final String from;
  final String to;
  final String busName;
  final String seatNumber;

  const TicketConfirmationScreen({
    required this.passengerName,
    required this.from,
    required this.to,
    required this.busName,
    required this.seatNumber,
    Key? key,
    required List<int> seats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Confirmation'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 20),

            _detailRow('Passenger:', passengerName),
            _detailRow('Bus Name:', busName),
            _detailRow('Route:', '$from → $to'),
            _detailRow('Seats:', seatNumber),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to HomeScreen and remove previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                    (route) => false, // remove all previous screens
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // green button
                  foregroundColor: Colors.white, // white text
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Generate Ticket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
