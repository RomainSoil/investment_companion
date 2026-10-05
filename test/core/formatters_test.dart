import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/core/utils/formatters.dart';

void main() {
  group('greetingFor', () {
    test('dit bonjour en journée', () {
      expect(greetingFor(DateTime(2026, 10, 5, 5)), 'Bonjour');
      expect(greetingFor(DateTime(2026, 10, 5, 9)), 'Bonjour');
      expect(greetingFor(DateTime(2026, 10, 5, 17, 59)), 'Bonjour');
    });

    test('dit bonsoir à partir de 18 h et pendant la nuit', () {
      expect(greetingFor(DateTime(2026, 10, 5, 18)), 'Bonsoir');
      expect(greetingFor(DateTime(2026, 10, 5, 23, 30)), 'Bonsoir');
      expect(greetingFor(DateTime(2026, 10, 5, 0)), 'Bonsoir');
      expect(greetingFor(DateTime(2026, 10, 5, 4, 59)), 'Bonsoir');
    });
  });

  group('formatTime', () {
    test('affiche les heures et les minutes sur deux chiffres', () {
      expect(formatTime(DateTime(2026, 10, 5, 9, 5)), '09:05');
      expect(formatTime(DateTime(2026, 10, 5, 16, 42)), '16:42');
      expect(formatTime(DateTime(2026, 10, 5)), '00:00');
    });
  });
}
