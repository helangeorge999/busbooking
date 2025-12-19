import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchInfo {
  final String? source;
  final String? destination;
  final String? date;

  SearchInfo({this.source, this.destination, this.date});

  SearchInfo copyWith({String? source, String? destination, String? date}) {
    return SearchInfo(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      date: date ?? this.date,
    );
  }
}

class SearchInfoNotifier extends StateNotifier<SearchInfo> {
  SearchInfoNotifier() : super(SearchInfo());

  void setSource(String source) => state = state.copyWith(source: source);
  void setDestination(String destination) =>
      state = state.copyWith(destination: destination);
  void setDate(String date) => state = state.copyWith(date: date);
}

final searchInfoProvider =
    StateNotifierProvider<SearchInfoNotifier, SearchInfo>(
      (ref) => SearchInfoNotifier(),
    );
