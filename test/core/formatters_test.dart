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

  group('formatDate', () {
    test('affiche jour, mois et année', () {
      expect(formatDate(DateTime(2016, 10, 6)), '06/10/2016');
    });
  });

  group('formatPrice', () {
    test('affiche deux décimales avec une virgule et la devise', () {
      expect(formatPrice(28.4725, 'USD'), '28,47 USD');
      expect(formatPrice(3, ''), '3,00');
    });
  });

  group('formatChange', () {
    test('affiche une variation signée en pourcentage', () {
      expect(formatChange(0.123), '+12,3 %');
      expect(formatChange(-0.04), '-4,0 %');
    });
  });
}
