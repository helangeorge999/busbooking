// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'register_screen.dart';

// class OnboardingScreen3 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo
//             Icon(Icons.directions_bus, size: 70, color: Colors.blue),
//             SizedBox(height: 0),

//             Text(
//               'BUS\nBOOKING',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),

//             SizedBox(height: 50),

//             // Title
//             Text(
//               'Login / Signup',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//             ),

//             SizedBox(height: 40),

//             // Already have account
//             Text(
//               'Already have an account?',
//               style: TextStyle(color: Colors.grey),
//             ),
//             SizedBox(height: 10),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text('Sign in', style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => LoginScreen()),
//                   );
//                 },
//               ),
//             ),

//             SizedBox(height: 25),

//             // Don't have account
//             Text(
//               "Don't have an account?",
//               style: TextStyle(color: Colors.grey),
//               //  height:10,
//               //  width,
//             ),
//             SizedBox(height: 10),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text('Sign up', style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => RegisterScreen()),
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
