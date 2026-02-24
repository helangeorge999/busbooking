import 'package:flutter/material.dart';
import 'bus_list_screen.dart';

class SearchBusScreen extends StatefulWidget {
  const SearchBusScreen({super.key});

  @override
  State<SearchBusScreen> createState() => _SearchBusScreenState();
}

class _SearchBusScreenState extends State<SearchBusScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool get _isFormValid =>
      _fromController.text.trim().isNotEmpty &&
      _toController.text.trim().isNotEmpty &&
      _dateController.text.trim().isNotEmpty;

  final List<String> _cities = [
    'Kathmandu',
    'Pokhara',
    'Biratnagar',
    'Birgunj',
    'Bharatpur',
    'Janakpur',
    'Butwal',
    'Dharan',
    'Hetauda',
    'Nepalgunj',
    'Dhangadhi',
    'Itahari',
    'Banepa',
    'Dhulikhel',
    'Bhaktapur',
    'Lalitpur',
    'Gorkha',
    'Besisahar',
    'Mugling',
    'Narayanghat',
  ];

  Future<void> _selectCity(
    TextEditingController controller,
    String title,
  ) async {
    final TextEditingController searchCtrl = TextEditingController();
    List<String> filtered = List.from(_cities);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search city...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            filtered = _cities
                                .where(
                                  (c) => c.toLowerCase().contains(
                                    val.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filtered.isEmpty ? 1 : filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            if (filtered.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No cities found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                            final city = filtered[i];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_city,
                                color: Color(0xFF1565C0),
                              ),
                              title: Text(city),
                              onTap: () {
                                setState(() => controller.text = city);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _onSearch() {
    if (!_isFormValid) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusListScreen(
          from: _fromController.text,
          to: _toController.text,
          date: _dateController.text,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fromController.addListener(() => setState(() {}));
    _toController.addListener(() => setState(() {}));
    _dateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Widget _cityTile({
    required TextEditingController controller,
    required String hint,
    required String title,
    required IconData icon,
  }) {
    final filled = controller.text.isNotEmpty;
    return GestureDetector(
      onTap: () => _selectCity(controller, title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: filled ? const Color(0xFF1565C0) : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: filled ? const Color(0xFF1565C0) : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                filled ? controller.text : hint,
                style: TextStyle(
                  fontSize: 14,
                  color: filled ? Colors.black : Colors.grey[500],
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Color(0xFF1565C0),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus Booking',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Find & book your seat',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Leaving From
              const Text(
                'Leaving From',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _cityTile(
                controller: _fromController,
                hint: 'Enter source city. (Eg: Kathmandu)',
                title: 'Select Departure City',
                icon: Icons.trip_origin,
              ),

              const SizedBox(height: 12),

              // Swap cities button
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final temp = _fromController.text;
                      _fromController.text = _toController.text;
                      _toController.text = temp;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.swap_vert,
                      color: Color(0xFF1565C0),
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Going Destination
              const Text(
                'Going Destination',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _cityTile(
                controller: _toController,
                hint: 'Enter destination city. (Eg: Pokhara)',
                title: 'Select Destination City',
                icon: Icons.location_on,
              ),

              const SizedBox(height: 20),

              // Travel Date
              const Text(
                'Travel Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _dateController.text.isNotEmpty
                          ? const Color(0xFF1565C0)
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _dateController.text.isNotEmpty
                            ? const Color(0xFF1565C0)
                            : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateController.text.isEmpty
                              ? 'YYYY-MM-DD'
                              : _dateController.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: _dateController.text.isEmpty
                                ? Colors.grey[500]
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Validation hint
              if (!_isFormValid)
                Text(
                  _fromController.text.isEmpty
                      ? '⚠ Please select a departure city'
                      : _toController.text.isEmpty
                      ? '⚠ Please select a destination city'
                      : '⚠ Please select a travel date',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),

              const SizedBox(height: 24),

              // Search Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? const Color(0xFF1565C0)
                        : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: _isFormValid ? 2 : 0,
                  ),
                  onPressed: _isFormValid ? _onSearch : null,
                  child: Text(
                    'Search Buses',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isFormValid ? Colors.white : Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
