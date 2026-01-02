import 'package:flutter/material.dart';
import 'home_screen.dart';

class TicketScreen extends StatelessWidget {
  final String passengerName;
  final String from;
  final String to;
  final String busName;
  final String seatNumber;

  const TicketScreen({
    super.key,
    required this.passengerName,
    required this.from,
    required this.to,
    required this.busName,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                buildTicketRow('Passenger:', passengerName),
                buildTicketRow('From:', from),
                buildTicketRow('To:', to),
                buildTicketRow('Bus Name:', busName),
                buildTicketRow('Seat Number:', seatNumber),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to HomeScreen and remove all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                      (route) => false, // remove all previous screens
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
