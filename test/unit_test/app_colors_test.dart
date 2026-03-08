import 'package:busbooking/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors Tests', () {
    test('Primary color should be blue shade', () {
      expect(AppColors.primary, const Color(0xFF1E88E5));
    });

    test('Background color should be light grey', () {
      expect(AppColors.background, const Color(0xFFF5F5F5));
    });

    test('Input fill color should be light blue', () {
      expect(AppColors.inputFill, const Color(0xFFE8F0FE));
    });

    test('Text dark color should be dark', () {
      expect(AppColors.textDark, const Color(0xFF212121));
    });

    test('Primary color should not be null', () {
      expect(AppColors.primary, isNotNull);
    });
  });
}
