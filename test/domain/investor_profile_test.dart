import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/domain/investor_profile.dart';

void main() {
  group('InvestorProfileType.fromStorage', () {
    test('retrouve chaque profil à partir de son nom enregistré', () {
      for (final type in InvestorProfileType.values) {
        expect(InvestorProfileType.fromStorage(type.name), type);
      }
    });

    test('renvoie null si la valeur est absente ou inconnue', () {
      expect(InvestorProfileType.fromStorage(null), isNull);
      expect(InvestorProfileType.fromStorage(''), isNull);
      expect(InvestorProfileType.fromStorage('inconnu'), isNull);
    });
  });

  test('chaque profil a un nom à afficher', () {
    expect(InvestorProfileType.prudent.label, 'Prudent');
    expect(InvestorProfileType.equilibre.label, 'Équilibré');
    expect(InvestorProfileType.dynamique.label, 'Dynamique');
  });
}
