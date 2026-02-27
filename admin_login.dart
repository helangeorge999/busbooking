import 'dart:io';

void main() {
  // Hardcoded admin credentials
  String adminId = "admin123";
  String adminPass = "pass123";

  // Taking input from terminal
  stdout.write("Enter Admin ID: ");
  String? inputId = stdin.readLineSync();

  stdout.write("Enter Password: ");
  String? inputPass = stdin.readLineSync();

  // Checking credentials
  if (inputId == adminId && inputPass == adminPass) {
    print("Login Successful ✅");
  } else {
    print("Invalid ID or Password ❌");
  }
}
