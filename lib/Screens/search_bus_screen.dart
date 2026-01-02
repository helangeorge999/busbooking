import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'available_bus_screen.dart';
import '../Providers/search_provider.dart';

class SearchBusScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchBusScreen> createState() => _SearchBusScreenState();
}

class _SearchBusScreenState extends ConsumerState<SearchBusScreen> {
  final List<String> cities = ['Kathmandu', 'Pokhara', 'Nepalgunj'];
  String? selectedSource;
  String? selectedDestination;
  final TextEditingController dateController = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        dateController.text = formattedDate;
      });
      // Update provider
      ref.read(searchInfoProvider.notifier).setDate(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search Bus'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('Leaving From', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            _dropdownField(
              hint: 'Select source city',
              value: selectedSource,
              onChanged: (value) {
                setState(() => selectedSource = value);
                if (value != null) {
                  ref.read(searchInfoProvider.notifier).setSource(value);
                }
              },
            ),
            SizedBox(height: 20),
            Text('Going To', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            _dropdownField(
              hint: 'Select destination city',
              value: selectedDestination,
              onChanged: (value) {
                setState(() => selectedDestination = value);
                if (value != null) {
                  ref.read(searchInfoProvider.notifier).setDestination(value);
                }
              },
            ),
            SizedBox(height: 20),
            Text('Travel Date', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                hintText: 'YYYY-MM-DD',
                suffixIcon: Icon(Icons.calendar_month),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Search Buses',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (selectedSource != null &&
                      selectedDestination != null &&
                      dateController.text.isNotEmpty) {
                    // Navigate to AvailableBusScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AvailableBusScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select source, destination, and date',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: cities
          .map((city) => DropdownMenuItem(value: city, child: Text(city)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
