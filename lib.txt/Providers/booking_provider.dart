import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model class for booking information
class BookingInfo {
  final String busName;
  final String from;
  final String to;
  final String date;
  final String seatNumber;

  BookingInfo({
    this.busName = '',
    this.from = '',
    this.to = '',
    this.date = '',
    this.seatNumber = '',
  });

  BookingInfo copyWith({
    String? busName,
    String? from,
    String? to,
    String? date,
    String? seatNumber,
  }) {
    return BookingInfo(
      busName: busName ?? this.busName,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      seatNumber: seatNumber ?? this.seatNumber,
    );
  }
}

// StateProvider for booking information
final bookingProvider = StateProvider<BookingInfo>((ref) => BookingInfo());
