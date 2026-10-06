import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/domain/asset.dart';
import 'package:investment_companion/domain/investor_profile.dart';
import 'package:investment_companion/domain/questionnaire.dart';

void main() {
  test('le score maximal du questionnaire est de 10 points', () {
    final maximum = profileQuestionnaire
        .map((question) => question.answers.map((a) => a.points).reduce(
              (a, b) => a > b ? a : b,
            ))
        .reduce((a, b) => a + b);

    expect(maximum, 10);
  });

  test('le score donne le profil', () {
    expect(profileForScore(0), InvestorProfileType.prudent);
    expect(profileForScore(3), InvestorProfileType.prudent);
    expect(profileForScore(4), InvestorProfileType.equilibre);
    expect(profileForScore(6), InvestorProfileType.equilibre);
    expect(profileForScore(7), InvestorProfileType.dynamique);
    expect(profileForScore(10), InvestorProfileType.dynamique);
  });

  test('chaque profil a des actifs conseillés, de son niveau de risque', () {
    for (final profile in InvestorProfileType.values) {
      expect(profile.advisedAssets, isNotEmpty);
      expect(
        profile.advisedAssets.map((asset) => asset.risk),
        everyElement(profile.advisedRisk),
      );
    }
  });

  test('chaque actif du catalogue est conseillé à un profil', () {
    final advised = {
      for (final profile in InvestorProfileType.values)
        ...profile.advisedAssets,
    };

    expect(advised, hasLength(assetCatalog.length));
    expect(assetBySymbol('NVDA')!.risk, RiskLevel.high);
  });
}
