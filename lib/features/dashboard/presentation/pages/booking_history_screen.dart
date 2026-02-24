import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  // In a real app this would come from your backend/local DB
  static const List<Map<String, String>> _history = [
    {
      'route': 'Kathmandu → Pokhara',
      'date': '2025-01-10',
      'seats': 'A1, A2',
      'amount': 'Rs. 4416',
      'status': 'Confirmed',
      'bus': 'Vip 2+1 Sofa seater',
    },
    {
      'route': 'Pokhara → Kathmandu',
      'date': '2025-01-15',
      'seats': 'B3',
      'amount': 'Rs. 2208',
      'status': 'Completed',
      'bus': 'Legend Gorkali Air bus',
    },
    {
      'route': 'Kathmandu → Butwal',
      'date': '2024-12-20',
      'seats': 'C2',
      'amount': 'Rs. 1490',
      'status': 'Cancelled',
      'bus': 'Ganapati Bus',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Booking History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No bookings yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, i) {
                final b = _history[i];
                final statusColor = _statusColor(b['status']!);

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route + status badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b['route']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                                b['status']!,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                        Text(
                          b['bus']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const Divider(height: 20),

                        _row(Icons.calendar_today_outlined, 'Date', b['date']!),
                        const SizedBox(height: 6),
                        _row(Icons.event_seat_outlined, 'Seat(s)', b['seats']!),
                        const SizedBox(height: 6),
                        _row(
                          Icons.currency_rupee,
                          'Amount',
                          b['amount']!,
                          bold: true,
                          color: Colors.blue[700],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
