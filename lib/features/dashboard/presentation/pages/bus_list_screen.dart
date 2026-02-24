import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';

class BusModel {
  final String name;
  final String type;
  final String departure;
  final String arrival;
  final String duration;
  final String from;
  final String to;
  final double price;
  final int availableSeats;

  BusModel({
    required this.name,
    required this.type,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.from,
    required this.to,
    required this.price,
    required this.availableSeats,
  });
}

class BusListScreen extends StatelessWidget {
  final String from;
  final String to;
  final String date;

  const BusListScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  List<BusModel> get _buses => [
    BusModel(
      name: 'Ganapati Bus',
      type: 'AC',
      departure: '6:00 P.M',
      arrival: '11:00 A.M',
      duration: '5 hrs',
      from: from.isEmpty ? 'Kathmandu' : from,
      to: to.isEmpty ? 'Pokhara' : to,
      price: 2208,
      availableSeats: 20,
    ),
    BusModel(
      name: 'Legend Gorkali Air bus',
      type: 'AC',
      departure: '6:30 P.M',
      arrival: '11:00 A.M',
      duration: '4.5 hrs',
      from: from.isEmpty ? 'Kathmandu' : from,
      to: to.isEmpty ? 'Pokhara' : to,
      price: 2208,
      availableSeats: 12,
    ),
    BusModel(
      name: 'Vip 2+1 Sofa seater',
      type: 'VIP',
      departure: '9:00 P.M',
      arrival: '2:30 A.M',
      duration: '5.5 hrs',
      from: from.isEmpty ? 'Kathmandu' : from,
      to: to.isEmpty ? 'Pokhara' : to,
      price: 1490,
      availableSeats: 8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Available Buses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _buses.length,
        itemBuilder: (context, index) {
          final bus = _buses[index];
          return _BusCard(bus: bus);
        },
      ),
    );
  }
}

class _BusCard extends StatelessWidget {
  final BusModel bus;
  const _BusCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bus.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              bus.type,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  bus.departure,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        bus.duration,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(thickness: 1),
                    ],
                  ),
                ),
                Text(
                  bus.arrival,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${bus.price.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    Text(
                      '${bus.availableSeats} seats left',
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeatSelectionScreen(bus: bus),
                    ),
                  );
                },
                child: const Text(
                  'View Seats',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
