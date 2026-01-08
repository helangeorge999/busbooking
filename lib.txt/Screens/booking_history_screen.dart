// import 'package:flutter/material.dart';

// class BookingHistoryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(title: Text('Booking History')),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           _historyCard(
//             busName: 'Vip 2+1 Sofa Seater',
//             route: 'Kathmandu → Pokhara',
//             date: '2025-01-12',
//             seats: 'S3, S4',
//             price: 'Rs. 2800',
//           ),
//           _historyCard(
//             busName: 'Legend Gorkhali Air Bus',
//             route: 'Kathmandu → Nepalgunj',
//             date: '2024-12-28',
//             seats: 'S10',
//             price: 'Rs. 2200',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _historyCard({
//     required String busName,
//     required String route,
//     required String date,
//     required String seats,
//     required String price,
//   }) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               busName,
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 6),
//             Text(route),
//             SizedBox(height: 6),
//             Text('Date: $date'),
//             Text('Seats: $seats'),
//             SizedBox(height: 6),
//             Text(
//               price,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
