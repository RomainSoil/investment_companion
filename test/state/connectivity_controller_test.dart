import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/state/connectivity_controller.dart';

import '../helpers/fakes.dart';

void main() {
  final fixedTime = DateTime(2026, 10, 5, 16, 42);

  group('ConnectivityController', () {
    test('est en cours de vérification tant que rien n’a répondu', () {
      final controller = ConnectivityController(FakeConnectivityService());

      expect(controller.status, ConnectionStatus.checking);
      expect(controller.lastCheckedAt, isNull);
      expect(controller.isRefreshing, isFalse);
    });

    test('passe en ligne quand Internet répond', () async {
      final controller = ConnectivityController(
        FakeConnectivityService(online: true),
        clock: () => fixedTime,
      );

      await controller.check();

      expect(controller.status, ConnectionStatus.online);
      expect(controller.isOnline, isTrue);
      expect(controller.lastCheckedAt, fixedTime);
    });

    test('passe hors connexion quand Internet ne répond pas', () async {
      final controller = ConnectivityController(
        FakeConnectivityService(online: false),
        clock: () => fixedTime,
      );

      await controller.check();

      expect(controller.status, ConnectionStatus.offline);
      expect(controller.isOnline, isFalse);
      expect(controller.lastCheckedAt, fixedTime);
    });

    test('passe hors connexion si la vérification échoue', () async {
      final controller = ConnectivityController(FailingConnectivityService());

      await controller.check();

      expect(controller.status, ConnectionStatus.offline);
    });

    test('prévient l’interface une fois la première vérification finie',
        () async {
      final controller = ConnectivityController(FakeConnectivityService());
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.check();

      expect(notifications, 1);
    });

    test('signale l’actualisation en gardant l’ancien résultat', () async {
      final service = PendingConnectivityService();
      final controller = ConnectivityController(service);

      final first = controller.check();
      service.requests.single.complete(true);
      await first;
      expect(controller.isRefreshing, isFalse);

      final second = controller.check();
      expect(controller.isRefreshing, isTrue);
      expect(controller.status, ConnectionStatus.online);

      service.requests.last.complete(false);
      await second;
      expect(controller.isRefreshing, isFalse);
      expect(controller.status, ConnectionStatus.offline);
    });

    test('ignore un appel pendant une vérification déjà en cours', () async {
      final service = PendingConnectivityService();
      final controller = ConnectivityController(service);

      final first = controller.check();
      final second = controller.check();
      expect(service.requests, hasLength(1));

      service.requests.single.complete(true);
      await Future.wait([first, second]);
      expect(controller.status, ConnectionStatus.online);
    });

    test('ne prévient plus personne après sa destruction', () async {
      final service = PendingConnectivityService();
      final controller = ConnectivityController(service);

      final pending = controller.check();
      controller.dispose();
      service.requests.single.complete(true);

      // Ne doit lever aucune exception.
      await pending;
    });
  });
}
