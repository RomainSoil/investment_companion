import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/data/app_preferences.dart';
import 'package:investment_companion/domain/investor_profile.dart';
import 'package:investment_companion/state/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Stockage factice en mémoire, pré-rempli avec [values].
  Future<AppPreferences> preferencesWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return AppPreferences(await SharedPreferences.getInstance());
  }

  group('AppController', () {
    test('affiche la bienvenue au premier lancement', () async {
      final controller = AppController(await preferencesWith({}));

      expect(controller.stage, AppStage.welcome);
      expect(controller.profile, isNull);
      expect(controller.hasProfile, isFalse);
    });

    test('ouvre directement l’application si la bienvenue a été vue', () async {
      final controller = AppController(
        await preferencesWith({AppPreferences.welcomeSeenKey: true}),
      );

      expect(controller.stage, AppStage.ready);
    });

    test('completeWelcome change d’étape, prévient et enregistre', () async {
      final preferences = await preferencesWith({});
      final controller = AppController(preferences);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.completeWelcome();

      expect(controller.stage, AppStage.ready);
      expect(notifications, 1);
      expect(preferences.welcomeSeen, isTrue);
      // Un nouveau contrôleur, comme après un redémarrage, repart de l'état
      // enregistré.
      expect(AppController(preferences).stage, AppStage.ready);
    });

    test('completeWelcome ne prévient qu’une fois', () async {
      final controller = AppController(await preferencesWith({}));
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.completeWelcome();
      await controller.completeWelcome();

      expect(notifications, 1);
    });

    test('showWelcomeAgain revient à la bienvenue et l’enregistre', () async {
      final preferences = await preferencesWith(
        {AppPreferences.welcomeSeenKey: true},
      );
      final controller = AppController(preferences);

      await controller.showWelcomeAgain();

      expect(controller.stage, AppStage.welcome);
      expect(preferences.welcomeSeen, isFalse);
    });

    test('relit le profil enregistré', () async {
      final controller = AppController(
        await preferencesWith({AppPreferences.profileTypeKey: 'equilibre'}),
      );

      expect(controller.profile, InvestorProfileType.equilibre);
      expect(controller.hasProfile, isTrue);
    });

    test('ignore un profil enregistré inconnu', () async {
      final controller = AppController(
        await preferencesWith({AppPreferences.profileTypeKey: 'inconnu'}),
      );

      expect(controller.profile, isNull);
    });

    test('setProfile enregistre le profil, puis l’efface', () async {
      final preferences = await preferencesWith({});
      final controller = AppController(preferences);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setProfile(InvestorProfileType.dynamique);

      expect(controller.profile, InvestorProfileType.dynamique);
      expect(preferences.profileType, InvestorProfileType.dynamique);
      expect(notifications, 1);

      await controller.setProfile(null);

      expect(controller.profile, isNull);
      expect(preferences.profileType, isNull);
      expect(notifications, 2);
    });
  });
}
