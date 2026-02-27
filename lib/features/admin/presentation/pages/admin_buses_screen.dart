import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── AdminBusesScreen ──────────────────────────────────────────────────────────
// GET    /api/buses           → list all buses
// POST   /api/buses           → create bus  (admin token)
// PATCH  /api/buses/:id       → update bus  (admin token)
// DELETE /api/buses/:id       → delete bus  (admin token)
// Fields match BusSchema: name, from, to, departureTime, arrivalTime,
//                         price, totalSeats, type, rating
class AdminBusesScreen extends StatefulWidget {
  const AdminBusesScreen({super.key});

  @override
  State<AdminBusesScreen> createState() => _AdminBusesScreenState();
}

class _AdminBusesScreenState extends State<AdminBusesScreen> {
  static const String _url = 'http://10.0.2.2:5050/api/buses';

  List<Map<String, dynamic>> _buses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<Map<String, String>> _headers() async {
    final p = await SharedPreferences.getInstance();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${p.getString('token') ?? ''}',
    };
  }

  // ── GET /api/buses ──────────────────────────────────────────────────────────
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(Uri.parse(_url), headers: await _headers());
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() {
          _buses = (body['data'] as List).cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() {
          _error = body['message'];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Network error';
        _loading = false;
      });
    }
  }

  // ── DELETE /api/buses/:id ───────────────────────────────────────────────────
  Future<void> _delete(String id, String name) async {
    final confirm = await _confirmDialog(
      'Delete Bus',
      'Delete "$name"? This cannot be undone.',
    );
    if (confirm != true) return;

    try {
      final res = await http.delete(
        Uri.parse('$_url/$id'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        _snack('Bus deleted', Colors.green);
        _fetch();
      } else {
        _snack(body['message'] ?? 'Failed to delete', Colors.red);
      }
    } catch (_) {
      _snack('Network error', Colors.red);
    }
  }

  // ── Show Add/Edit bottom sheet ──────────────────────────────────────────────
  void _showForm({Map<String, dynamic>? bus}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BusFormSheet(
        bus: bus,
        onSaved: (data) async {
          Navigator.pop(context);
          if (bus == null) {
            await _create(data);
          } else {
            await _update(bus['_id'], data);
          }
        },
      ),
    );
  }

  // ── POST /api/buses ─────────────────────────────────────────────────────────
  Future<void> _create(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: await _headers(),
        body: jsonEncode(data),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201 && body['success'] == true) {
        _snack('Bus added successfully', Colors.green);
        _fetch();
      } else {
        _snack(body['message'] ?? 'Failed to create bus', Colors.red);
      }
    } catch (_) {
      _snack('Network error', Colors.red);
    }
  }

  // ── PATCH /api/buses/:id ────────────────────────────────────────────────────
  Future<void> _update(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.patch(
        Uri.parse('$_url/$id'),
        headers: await _headers(),
        body: jsonEncode(data),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        _snack('Bus updated', Colors.green);
        _fetch();
      } else {
        _snack(body['message'] ?? 'Failed to update', Colors.red);
      }
    } catch (_) {
      _snack('Network error', Colors.red);
    }
  }

  Future<bool?> _confirmDialog(
    String title,
    String content,
  ) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1565C0)),
            )
          : _error != null
          ? _errorView()
          : _buses.isEmpty
          ? _emptyView()
          : RefreshIndicator(
              onRefresh: _fetch,
              color: const Color(0xFF1565C0),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _buses.length,
                itemBuilder: (_, i) => _BusTile(
                  bus: _buses[i],
                  onEdit: () => _showForm(bus: _buses[i]),
                  onDelete: () =>
                      _delete(_buses[i]['_id'], _buses[i]['name'] ?? ''),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Bus', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _errorView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _fetch,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
          ),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_bus, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text(
          'No buses yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap + Add Bus to create a route',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

// ── Bus Tile ──────────────────────────────────────────────────────────────────
class _BusTile extends StatelessWidget {
  final Map<String, dynamic> bus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BusTile({
    required this.bus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bus['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Type badge
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
                    bus['type'] ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Route row
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${bus['from']} → ${bus['to']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Time row
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${bus['departureTime']} → ${bus['arrivalTime']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      size: 14,
                      color: Color(0xFF1565C0),
                    ),
                    Text(
                      '${bus['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.event_seat, size: 14, color: Colors.green),
                    const SizedBox(width: 3),
                    Text(
                      '${bus['totalSeats']} seats',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Edit
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.teal,
                        size: 20,
                      ),
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    // Delete
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bus Form Bottom Sheet ─────────────────────────────────────────────────────
class _BusFormSheet extends StatefulWidget {
  final Map<String, dynamic>? bus; // null = create, non-null = edit
  final void Function(Map<String, dynamic>) onSaved;

  const _BusFormSheet({this.bus, required this.onSaved});

  @override
  State<_BusFormSheet> createState() => _BusFormSheetState();
}

class _BusFormSheetState extends State<_BusFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  late final TextEditingController _depCtrl;
  late final TextEditingController _arrCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _seatsCtrl;
  late final TextEditingController _ratingCtrl;
  String _busType = 'AC';

  final List<String> _types = ['AC', 'Non-AC', 'VIP', 'Deluxe', 'Sleeper'];

  @override
  void initState() {
    super.initState();
    final b = widget.bus;
    _nameCtrl = TextEditingController(text: b?['name'] ?? '');
    _fromCtrl = TextEditingController(text: b?['from'] ?? '');
    _toCtrl = TextEditingController(text: b?['to'] ?? '');
    _depCtrl = TextEditingController(text: b?['departureTime'] ?? '');
    _arrCtrl = TextEditingController(text: b?['arrivalTime'] ?? '');
    _priceCtrl = TextEditingController(text: b?['price']?.toString() ?? '');
    _seatsCtrl = TextEditingController(
      text: b?['totalSeats']?.toString() ?? '40',
    );
    _ratingCtrl = TextEditingController(
      text: b?['rating']?.toString() ?? '4.0',
    );
    _busType = b?['type'] ?? 'AC';
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _fromCtrl,
      _toCtrl,
      _depCtrl,
      _arrCtrl,
      _priceCtrl,
      _seatsCtrl,
      _ratingCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSaved({
      'name': _nameCtrl.text.trim(),
      'from': _fromCtrl.text.trim(),
      'to': _toCtrl.text.trim(),
      'departureTime': _depCtrl.text.trim(),
      'arrivalTime': _arrCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'totalSeats': int.tryParse(_seatsCtrl.text.trim()) ?? 40,
      'type': _busType,
      'rating': double.tryParse(_ratingCtrl.text.trim()) ?? 4.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bus != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Edit Bus Route' : 'Add New Bus Route',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Bus Name
              _field(
                _nameCtrl,
                'Bus Name',
                Icons.directions_bus_outlined,
                'e.g. Ganapati Express',
              ),

              const SizedBox(height: 12),
              // From / To row
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _fromCtrl,
                      'From',
                      Icons.my_location,
                      'e.g. Kathmandu',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      _toCtrl,
                      'To',
                      Icons.location_on,
                      'e.g. Pokhara',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Departure / Arrival row
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _depCtrl,
                      'Departure Time',
                      Icons.access_time,
                      'e.g. 6:00 PM',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      _arrCtrl,
                      'Arrival Time',
                      Icons.access_time_filled,
                      'e.g. 11:00 PM',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Price / Seats row
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _priceCtrl,
                      'Price (Rs.)',
                      Icons.currency_rupee,
                      'e.g. 1500',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      _seatsCtrl,
                      'Total Seats',
                      Icons.event_seat,
                      'e.g. 40',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _busType,
                decoration: InputDecoration(
                  labelText: 'Bus Type',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _busType = v!),
              ),

              const SizedBox(height: 12),
              // Rating
              _field(
                _ratingCtrl,
                'Rating (0–5)',
                Icons.star_outline,
                'e.g. 4.5',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final r = double.tryParse(v ?? '');
                  if (r == null || r < 0 || r > 5) {
                    return 'Enter 0–5';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    isEdit ? 'Update Bus Route' : 'Add Bus Route',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      validator:
          validator ??
          (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
    );
  }
}
