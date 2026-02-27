import 'package:flutter/material.dart';
import 'passenger_detail_screen.dart';
import 'bus_list_screen.dart';

enum SeatStatus { booked, available, selected }

class SeatModel {
  final String label;
  SeatStatus status;

  SeatModel({required this.label, required this.status});
}

class SeatSelectionScreen extends StatefulWidget {
  final BusModel bus;
  const SeatSelectionScreen({super.key, required this.bus});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late List<List<SeatModel?>> seatGrid;

  @override
  void initState() {
    super.initState();
    _initSeats();
  }

  void _initSeats() {
    // 2+2 layout: 4 seats per row with aisle in middle, 10 rows
    const bookedSeats = {
      'A1',
      'A4',
      'B2',
      'C3',
      'D1',
      'D4',
      'E2',
      'F1',
      'G3',
      'H4',
      'I1',
      'J2',
    };
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

    seatGrid = rows.map((row) {
      return [
        SeatModel(
          label: '${row}1',
          status: bookedSeats.contains('${row}1')
              ? SeatStatus.booked
              : SeatStatus.available,
        ),
        SeatModel(
          label: '${row}2',
          status: bookedSeats.contains('${row}2')
              ? SeatStatus.booked
              : SeatStatus.available,
        ),
        null, // aisle gap
        SeatModel(
          label: '${row}3',
          status: bookedSeats.contains('${row}3')
              ? SeatStatus.booked
              : SeatStatus.available,
        ),
        SeatModel(
          label: '${row}4',
          status: bookedSeats.contains('${row}4')
              ? SeatStatus.booked
              : SeatStatus.available,
        ),
      ];
    }).toList();
  }

  List<String> get selectedSeats {
    final selected = <String>[];
    for (final row in seatGrid) {
      for (final seat in row) {
        if (seat != null && seat.status == SeatStatus.selected) {
          selected.add(seat.label);
        }
      }
    }
    return selected;
  }

  void _onSeatTap(SeatModel seat) {
    if (seat.status == SeatStatus.booked) return;
    setState(() {
      seat.status = seat.status == SeatStatus.selected
          ? SeatStatus.available
          : SeatStatus.selected;
    });
  }

  void _showConfirmationDialog() {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Confirm payment?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seat(s): ${selectedSeats.join(', ')}'),
            const SizedBox(height: 6),
            Text(
              'Total: Rs. ${(widget.bus.price * selectedSeats.length).toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PassengerDetailScreen(
                    bus: widget.bus,
                    selectedSeats: selectedSeats,
                  ),
                ),
              );
            },
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _seatColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.booked:
        return Colors.pink[100]!;
      case SeatStatus.selected:
        return const Color(0xFF1565C0);
      case SeatStatus.available:
        return Colors.green[200]!;
    }
  }

  Color _seatBorderColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.booked:
        return Colors.pink[300]!;
      case SeatStatus.selected:
        return const Color(0xFF0D47A1);
      case SeatStatus.available:
        return Colors.green[400]!;
    }
  }

  Widget _buildSeat(SeatModel? seat) {
    // Aisle gap
    if (seat == null) return const SizedBox(width: 20);

    return GestureDetector(
      onTap: () => _onSeatTap(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _seatColor(seat.status),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _seatBorderColor(seat.status), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat,
              size: 18,
              color: seat.status == SeatStatus.selected
                  ? Colors.white
                  : Colors.grey[700],
            ),
            Text(
              seat.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: seat.status == SeatStatus.selected
                    ? Colors.white
                    : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = selectedSeats;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bus.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              '${widget.bus.from} → ${widget.bus.to}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Bus front indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        size: 20,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available Seats',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Column headers: window / aisle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerLabel('A'),
                _headerLabel('B'),
                const SizedBox(width: 28),
                _headerLabel('C'),
                _headerLabel('D'),
              ],
            ),
          ),

          // Seat grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: seatGrid.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final row = entry.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row number label
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${rowIndex + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...row.map((seat) => _buildSeat(seat)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Legend
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(Colors.pink[100]!, Colors.pink[300]!, 'Booked'),
                const SizedBox(width: 20),
                _legend(Colors.green[200]!, Colors.green[400]!, 'Available'),
                const SizedBox(width: 20),
                _legend(
                  const Color(0xFF1565C0),
                  const Color(0xFF0D47A1),
                  'Selected',
                ),
              ],
            ),
          ),

          // Selected summary + Continue button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                if (selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected: ${selected.join(', ')}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Rs. ${(widget.bus.price * selected.length).toInt()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected.isNotEmpty
                          ? const Color(0xFF1565C0)
                          : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _showConfirmationDialog,
                    child: Text(
                      selected.isEmpty
                          ? 'Select a Seat to Continue'
                          : 'Continue (${selected.length} seat${selected.length > 1 ? 's' : ''})',
                      style: TextStyle(
                        color: selected.isNotEmpty
                            ? Colors.white
                            : Colors.grey[500],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String label) {
    return SizedBox(
      width: 56,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _legend(Color fill, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
