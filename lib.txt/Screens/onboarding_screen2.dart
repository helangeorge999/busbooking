// import 'package:flutter/material.dart';
// import 'onboarding_screen3.dart';

// class OnboardingScreen2 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.orangeAccent, // different background color

//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.confirmation_num, // ticket icon
//               size: 100,
//               color: Colors.white,
//             ),

//             SizedBox(height: 30),

//             Text(
//               'Easy Ticket Booking',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),

//             SizedBox(height: 15),

//             Text(
//               'Select your bus, choose your seat, and pay securely in just a few taps.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16, color: Colors.black),
//             ),

//             SizedBox(height: 60),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white, // button color
//                   foregroundColor: Colors.orangeAccent, // text color
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text('Next'),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => OnboardingScreen3()),
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
