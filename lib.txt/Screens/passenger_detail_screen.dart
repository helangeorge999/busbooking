// import 'package:flutter/material.dart';
// import 'ticket_screen.dart';

// class PassengerDetailScreen extends StatefulWidget {
//   final String busName;
//   final String from;
//   final String to;
//   final String date;

//   const PassengerDetailScreen({
//     super.key,
//     required this.busName,
//     required this.from,
//     required this.to,
//     required this.date,
//   });

//   @override
//   State<PassengerDetailScreen> createState() => _PassengerDetailScreenState();
// }

// class _PassengerDetailScreenState extends State<PassengerDetailScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController seatController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Passenger Details')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(
//                 labelText: 'Passenger Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: seatController,
//               decoration: InputDecoration(
//                 labelText: 'Seat Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: Text(
//                   'Generate Ticket',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 onPressed: () {
//                   if (nameController.text.isEmpty ||
//                       seatController.text.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Please fill all fields')),
//                     );
//                     return;
//                   }

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TicketScreen(
//                         passengerName: nameController.text,
//                         from: widget.from,
//                         to: widget.to,
//                         busName: widget.busName,
//                         seatNumber: seatController.text,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
