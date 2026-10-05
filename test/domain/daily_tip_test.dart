import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/domain/daily_tip.dart';
import 'package:investment_companion/domain/investor_profile.dart';

void main() {
  const general = DailyTip(text: 'pour tous');
  const prudentOnly = DailyTip(
    text: 'prudent',
    profiles: [InvestorProfileType.prudent],
  );
  const dynamicOnly = DailyTip(
    text: 'dynamique',
    profiles: [InvestorProfileType.dynamique],
  );

  group('DailyTip.suits', () {
    test('un conseil sans profil convient à tout le monde', () {
      expect(general.suits(null), isTrue);
      expect(general.suits(InvestorProfileType.prudent), isTrue);
    });

    test('un conseil réservé à un profil ne convient qu’à ce profil', () {
      expect(prudentOnly.suits(InvestorProfileType.prudent), isTrue);
      expect(prudentOnly.suits(InvestorProfileType.dynamique), isFalse);
      expect(prudentOnly.suits(null), isFalse);
    });
  });

  group('tipOfTheDay', () {
    test('donne le même conseil toute la journée', () {
      final morning = tipOfTheDay(date: DateTime(2026, 10, 5, 8));
      final evening = tipOfTheDay(date: DateTime(2026, 10, 5, 22));

      expect(evening.text, morning.text);
    });

    test('change de conseil le lendemain', () {
      const tips = [
        DailyTip(text: 'a'),
        DailyTip(text: 'b'),
        DailyTip(text: 'c'),
      ];

      final today = tipOfTheDay(date: DateTime(2026, 10, 5), tips: tips);
      final tomorrow = tipOfTheDay(date: DateTime(2026, 10, 6), tips: tips);

      expect(tomorrow.text, isNot(today.text));
    });

    test('sans profil, ne propose que des conseils valables pour tous', () {
      for (var day = 1; day <= 28; day++) {
        final tip = tipOfTheDay(date: DateTime(2026, 2, day));

        expect(tip.profiles, isNull);
      }
    });

    test('ne propose jamais le conseil d’un autre profil', () {
      const tips = [general, prudentOnly, dynamicOnly];

      for (var day = 1; day <= 28; day++) {
        final tip = tipOfTheDay(
          date: DateTime(2026, 2, day),
          profile: InvestorProfileType.prudent,
          tips: tips,
        );

        expect(tip.text, isNot('dynamique'));
      }
    });

    test('propose quand même un conseil si aucun ne convient', () {
      final tip = tipOfTheDay(
        date: DateTime(2026, 10, 5),
        profile: InvestorProfileType.prudent,
        tips: const [dynamicOnly],
      );

      expect(tip.text, 'dynamique');
    });
  });

  group('dailyTips', () {
    test('contient des conseils valables pour tous, tous renseignés', () {
      expect(dailyTips.where((tip) => tip.profiles == null), isNotEmpty);
      for (final tip in dailyTips) {
        expect(tip.text.trim(), isNotEmpty);
      }
    });
  });
}
