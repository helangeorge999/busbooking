import 'package:busbooking/features/onboarding/domain/entities/onboarding_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingItem Tests', () {
    test('OnboardingItem should store title correctly', () {
      const item = OnboardingItem(
        title: 'Welcome',
        description: 'Book your bus easily',
        icon: Icons.directions_bus,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlue],
      );
      expect(item.title, 'Welcome');
    });

    test('OnboardingItem description should not be empty', () {
      const item = OnboardingItem(
        title: 'Welcome',
        description: 'Book your bus easily',
        icon: Icons.directions_bus,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlue],
      );
      expect(item.description.isNotEmpty, true);
    });

    test('OnboardingItem should have gradient colors', () {
      const item = OnboardingItem(
        title: 'Welcome',
        description: 'Book your bus easily',
        icon: Icons.directions_bus,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlue],
      );
      expect(item.gradientColors.length, 2);
    });

    test('OnboardingItem icon should be set', () {
      const item = OnboardingItem(
        title: 'Welcome',
        description: 'Book your bus easily',
        icon: Icons.directions_bus,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlue],
      );
      expect(item.icon, Icons.directions_bus);
    });

    test('OnboardingItem color should be set', () {
      const item = OnboardingItem(
        title: 'Welcome',
        description: 'Book your bus easily',
        icon: Icons.directions_bus,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlue],
      );
      expect(item.color, Colors.blue);
    });
  });
}
