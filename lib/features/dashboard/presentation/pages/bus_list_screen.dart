import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'seat_selection_screen.dart';

// ── BusModel matches backend bus.model.ts exactly ────────────────────────────
// Schema fields: name, from, to, departureTime, arrivalTime,
//                price, totalSeats, type, rating
class BusModel {
  final String id;
  final String name;
  final String from;
  final String to;
  final String departure; // maps to departureTime
  final String arrival; // maps to arrivalTime
  final double price;
  final int totalSeats;
  final String type;
  final double rating;

  // Computed — no duration field in backend so we skip it
  String get duration => '';

  BusModel({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.price,
    required this.totalSeats,
    required this.type,
    required this.rating,
  });

  /// Maps exactly to backend BusSchema field names
  factory BusModel.fromJson(Map<String, dynamic> j) {
    return BusModel(
      id: j['_id'] ?? '',
      name: j['name'] ?? '',
      from: j['from'] ?? '',
      to: j['to'] ?? '',
      departure: j['departureTime'] ?? '',
      arrival: j['arrivalTime'] ?? '',
      price: (j['price'] ?? 0).toDouble(),
      totalSeats: j['totalSeats'] ?? 40,
      type: j['type'] ?? '',
      rating: (j['rating'] ?? 4.0).toDouble(),
    );
  }
}

// ── BusListScreen ─────────────────────────────────────────────────────────────
// Backend endpoint: GET /api/buses/search?from=&to=  (bus.route.ts — public)
// Response shape:  { success: true, data: IBus[] }
class BusListScreen extends StatefulWidget {
  final String from;
  final String to;
  final String date;

  const BusListScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  // Backend base URL — matches index.ts PORT=5050, /api/buses mounted
  static const String _baseUrl = 'http://10.0.2.2:5050/api/buses';

  List<BusModel> _buses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  /// GET /api/buses/search?from=&to=
  /// BusController.search filters by from & to query params
  Future<void> _fetchBuses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Build URI with query params matching BusController.search
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          if (widget.from.isNotEmpty) 'from': widget.from,
          if (widget.to.isNotEmpty) 'to': widget.to,
          // date param available in query string for future filtering
          if (widget.date.isNotEmpty) 'date': widget.date,
        },
      );

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        // Response: { success: true, data: [...] }
        final List<dynamic> list = body['data'] ?? [];
        setState(() {
          _buses = list.map((e) => BusModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = body['message'] ?? 'Failed to load buses';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Buses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${widget.from} → ${widget.to}  •  ${widget.date}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBuses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Loading ──────────────────────────────────────────────────────────────
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1565C0)),
            SizedBox(height: 16),
            Text(
              'Searching for buses…',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // ── Network / server error ────────────────────────────────────────────────
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _fetchBuses,
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty — admin hasn't added any routes yet ────────────────────────────
    if (_buses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bus_filled,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              const Text(
                'No Buses Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'No buses found for\n${widget.from} → ${widget.to}'
                '\non ${widget.date}.\n\n'
                'Routes are managed by admin.\nPlease try a different route or date.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1565C0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
                label: const Text(
                  'Go Back',
                  style: TextStyle(color: Color(0xFF1565C0)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    // ── Bus list ─────────────────────────────────────────────────────────────
    return RefreshIndicator(
      color: const Color(0xFF1565C0),
      onRefresh: _fetchBuses,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _buses.length,
        itemBuilder: (_, i) => _BusCard(bus: _buses[i]),
      ),
    );
  }
}

// ── Bus Card ──────────────────────────────────────────────────────────────────
class _BusCard extends StatelessWidget {
  final BusModel bus;
  const _BusCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bus name + type badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bus.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bus.type,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Time row — departureTime → arrivalTime
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.departure,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      bus.from,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
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
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          const Icon(
                            Icons.directions_bus,
                            size: 14,
                            color: Color(0xFF1565C0),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
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
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bus.arrival,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      bus.to,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 3),
                Text(
                  bus.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // Price + seats + button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${bus.price.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_seat,
                          size: 13,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${bus.totalSeats} seats',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onPressed: bus.totalSeats > 0
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeatSelectionScreen(bus: bus),
                          ),
                        )
                      : null,
                  child: Text(
                    bus.totalSeats > 0 ? 'View Seats' : 'Full',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
