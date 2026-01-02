// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../Providers/booking_provider.dart';
// import 'booking_detail_screen.dart';

// class SeatSelectionScreen extends ConsumerStatefulWidget {
//   final int totalSeats;
//   final int bookedSeats;

//   const SeatSelectionScreen({
//     required this.totalSeats,
//     required this.bookedSeats,
//     Key? key,
//   }) : super(key: key);

//   @override
//   ConsumerState<SeatSelectionScreen> createState() =>
//       _SeatSelectionScreenState();
// }

// class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
//   late List<String> seats;
//   late Set<int> booked;
//   Set<int> selected = {};

//   @override
//   void initState() {
//     super.initState();

//     // Create seat labels
//     seats = List.generate(widget.totalSeats, (i) {
//       if (i < 20) return 'A${i + 1}';
//       if (i < 40) return 'B${i - 19}';
//       return 'C${i - 39}';
//     });

//     booked = Set.from(List.generate(widget.bookedSeats, (i) => i));
//   }

//   Widget seatBox(int index) {
//     final isBooked = booked.contains(index);
//     final isSelected = selected.contains(index);

//     return GestureDetector(
//       onTap: isBooked
//           ? null
//           : () {
//               setState(() {
//                 if (isSelected) {
//                   selected.remove(index);
//                 } else {
//                   selected.add(index);
//                 }
//               });
//             },
//       child: Container(
//         alignment: Alignment.center,
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: isBooked
//               ? Colors.brown.shade200
//               : isSelected
//               ? Colors.blue
//               : Colors.green,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Text(
//           seats[index],
//           style: const TextStyle(
//             fontSize: 11,
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: AppBar(
//         title: const Text('Available Seats'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'VIP 2+1 Sofa Seater',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               /// Main bus layout
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: 20,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             mainAxisSpacing: 10,
//                             crossAxisSpacing: 10,
//                             childAspectRatio: 1,
//                           ),
//                       itemBuilder: (_, i) => seatBox(i),
//                     ),
//                   ),
//                   const SizedBox(width: 30),
//                   Expanded(
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: 20,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             mainAxisSpacing: 10,
//                             crossAxisSpacing: 10,
//                             childAspectRatio: 1,
//                           ),
//                       itemBuilder: (_, i) => seatBox(i + 20),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(5, (i) => seatBox(i + 40)),
//               ),

//               const SizedBox(height: 20),

//               /// Legend
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: const [
//                   _Legend(color: Colors.brown, label: 'Booked'),
//                   _Legend(color: Colors.green, label: 'Available'),
//                   _Legend(color: Colors.blue, label: 'Selected'),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               /// Continue button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: selected.isEmpty
//                       ? null
//                       : () {
//                           // Map selected indices to seat labels
//                           final selectedSeat = selected
//                               .map((i) {
//                                 if (i < 20) return 'A${i + 1}';
//                                 if (i < 40) return 'B${i - 19}';
//                                 return 'C${i - 39}';
//                               })
//                               .join(', ');

//                           // Update bookingProvider
//                           ref
//                               .read(bookingProvider.notifier)
//                               .update(
//                                 (state) =>
//                                     state.copyWith(seatNumber: selectedSeat),
//                               );

//                           // Navigate to BookingDetailScreen
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => BookingDetailScreen(),
//                             ),
//                           );
//                         },
//                   child: const Text(
//                     'Continue',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _Legend extends StatelessWidget {
//   final Color color;
//   final String label;

//   const _Legend({required this.color, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(width: 14, height: 14, color: color),
//         const SizedBox(width: 6),
//         Text(label),
//       ],
//     );
//   }
// }
