import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint_1/Providers/search_provider.dart';
import 'seat_selection_screen.dart';
import '../Providers/booking_provider.dart';

class AvailableBusScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchInfo = ref.watch(searchInfoProvider);

    final List<Map<String, dynamic>> buses = [
      {
        'name': 'Legend Gorkhali Air bus',
        'type': 'AC',
        'from': 'Pokhara',
        'to': 'Nepalgunj',
        'fromTime': '5:30 PM',
        'toTime': '6:00 AM',
        'price': 'Rs. 1600',
        'totalSeats': 45,
        'bookedSeats': 10, // Number of booked seats
      },
      {
        'name': 'Legend Gorkhali Air bus',
        'type': 'AC',
        'from': 'Kathmandu',
        'to': 'Nepalgunj',
        'fromTime': '5:30 PM',
        'toTime': '11:00 AM',
        'price': 'Rs. 2200',
        'totalSeats': 45,
        'bookedSeats': 0, // Number of booked seats
      },
      {
        'name': 'Legend Gorkhali Air bus',
        'type': 'AC',
        'from': 'Kathmandu',
        'to': 'Nepalgunj',
        'fromTime': '6:30 PM',
        'toTime': '12:00 AM',
        'price': 'Rs. 2200',
        'totalSeats': 45,
        'bookedSeats': 9, // Number of booked seats
      },
      {
        'name': 'Pokhara Express',
        'type': 'Non-AC',
        'from': 'Pokhara',
        'to': 'Nepalgunj',
        'fromTime': '6:00 AM',
        'toTime': '12:00 PM',
        'price': 'Rs. 1800',
        'totalSeats': 45,
        'bookedSeats': 13,
      },
    ];

    final filteredBuses = buses
        .where(
          (bus) =>
              bus['from'] == searchInfo.source &&
              bus['to'] == searchInfo.destination,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Buses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (searchInfo.source != null && searchInfo.destination != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'From: ${searchInfo.source} → To: ${searchInfo.destination}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            if (filteredBuses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No buses available for this route.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            if (filteredBuses.isNotEmpty)
              Expanded(
                child: ListView(
                  children: filteredBuses.map((bus) {
                    return _busCard(context, ref, bus);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _busCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> bus,
  ) {
    final int totalSeats = bus['totalSeats'] as int;
    final int bookedSeats = bus['bookedSeats'] as int;
    final int availableSeats = totalSeats - bookedSeats;

    return Card(
      color: Colors.grey.shade200,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bus['name'], style: TextStyle(fontWeight: FontWeight.w600)),
            Text(bus['type'], style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus['fromTime'],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(bus['from'], style: TextStyle(fontSize: 12)),
                  ],
                ),
                Text(
                  '----------- Time -----------',
                  style: TextStyle(fontSize: 12),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bus['toTime'],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(bus['to'], style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus['price'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$availableSeats seats available',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'View Seats',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Update provider before navigating
                    ref
                        .read(bookingProvider.notifier)
                        .update(
                          (state) => state.copyWith(
                            busName: bus['name'],
                            from: bus['from'],
                            to: bus['to'],
                            date: '2025-12-20',
                          ),
                        );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeatSelectionScreen(
                          totalSeats: bus['totalSeats'],
                          bookedSeats: bus['bookedSeats'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
