# Investment Companion

Application Flutter pédagogique : le compagnon du débutant en investissement.
Projet du module Compilation et Développement d'Applications Mobiles
(Romain Soil, Camille Delot).

## Ce qui est fait à cette étape

- **Écran de bienvenue** (premier lancement) : présentation, courbe animée,
  « Définir mon profil » ou « Explorer sans profil ». Pas de compte.
- **Accueil** : profil défini ou non, état de la connexion, conseil du jour,
  quatre tuiles vers les fonctionnalités.
- **Navigation** : barre à cinq onglets. Les onglets Calculer, Apprendre,
  Simulations et Profil affichent un écran provisoire.

## Lancer le projet

Il faut Flutter avec Dart 3.5 ou plus récent (`flutter --version`).

Cette archive contient le code (`lib/`, `test/`, `assets/`, `pubspec.yaml`),
mais pas les dossiers propres à chaque plateforme (`android/`, `ios/`…).
La première commande les crée sans toucher aux fichiers existants :

```bash
flutter create --project-name investment_companion .
flutter pub get
flutter analyze
flutter test
flutter run
```

Si vous avez déjà créé un projet Flutter, copiez-y `lib/`, `test/` et
`assets/`, puis reportez dans votre `pubspec.yaml` les dépendances
(`flutter_localizations`, `provider`, `shared_preferences`) et la section
`fonts`.

## Organisation du code

```
lib/
  main.dart                 point d'entrée : ouvre le stockage local, lance l'app
  app.dart                  crée les contrôleurs et choisit l'écran à afficher
  core/
    theme/                  couleurs, styles de texte, thème Material
    utils/formatters.dart   salutation, format de l'heure
    widgets/                widgets réutilisables (pastille)
  domain/                   objets métier, sans Flutter : profil, conseil du jour
  data/                     accès au téléphone et au réseau
    app_preferences.dart    lecture et écriture des préférences
    connectivity_service.dart   test de la connexion à Internet
  state/                    état partagé (ChangeNotifier)
    app_controller.dart     étape de l'application, profil investisseur
    connectivity_controller.dart   en ligne, hors connexion, actualisation
    navigation_controller.dart     onglet affiché
  features/
    welcome/                écran de bienvenue et sa courbe animée
    home/                   accueil et ses widgets
    shell/                  barre de navigation, écrans provisoires
test/                       tests unitaires et tests de widgets
```

## Gestion de l'état (Provider)

- **Où se trouve l'état ?** Dans trois contrôleurs `ChangeNotifier` créés dans
  `app.dart`, au-dessus de tous les écrans. Les écrans ne gardent aucun état
  métier : ils lisent les contrôleurs avec `context.watch` ou
  `context.select`, et déclenchent des actions avec `context.read`.
- **Que se passe-t-il quand un widget est reconstruit ?** Rien n'est perdu :
  l'état vit dans les contrôleurs, pas dans les widgets. Seul l'état local
  d'un écran reste dans son widget, comme l'animation de la courbe
  (`GrowthChart`, un `StatefulWidget`).
- **Qui est responsable de la persistance ?** `AppPreferences` uniquement.
  Les contrôleurs lui demandent de lire ou d'enregistrer ; les écrans ne
  connaissent pas `shared_preferences`.
- **États de la connexion** : vérification en cours, en ligne, hors
  connexion, et actualisation (une nouvelle vérification pendant que l'ancien
  résultat reste affiché). Une erreur pendant la vérification est traitée
  comme « hors connexion ».
- **États métier déjà gérés** : première ouverture ou non, profil défini ou
  non.

## Animation

La courbe de l'écran de bienvenue est une animation codée :
`AnimationController` et `CurvedAnimation` font passer une progression de 0 à
1, et `GrowthChartPainter` (un `CustomPainter`) ne dessine que la partie de la
courbe correspondant à cette progression.

## Tests

`flutter test` lance :

- des tests unitaires de la logique : contrôleurs, choix du conseil du jour,
  profil, formats ;
- des tests de widgets du parcours : bienvenue, accueil, hors connexion,
  navigation.

Les tests n'utilisent ni le vrai stockage ni le vrai réseau : ils passent par
les versions factices de `test/helpers/fakes.dart`.

## Réseau : deux réglages à prévoir

L'application teste la connexion en joignant `api.twelvedata.com` (l'API de
cours prévue). Ces réglages seront aussi nécessaires pour appeler l'API.

- **Android, version release** : ajouter dans
  `android/app/src/main/AndroidManifest.xml`
  `<uses-permission android:name="android.permission.INTERNET"/>`.
  En mode debug, Flutter l'ajoute déjà.
- **macOS (application de bureau)** : ajouter la clé
  `com.apple.security.network.client` (valeur `true`) dans
  `macos/Runner/DebugProfile.entitlements` et `Release.entitlements`. Sans
  elle, l'application se croit hors connexion.

## Polices

DM Sans et Fraunces sont embarquées dans `assets/fonts/` (sous-ensemble
latin), sous licence SIL Open Font License 1.1 : voir `OFL-DMSans.txt` et
`OFL-Fraunces.txt`.

## Prochaines étapes

1. Questionnaire de profil investisseur (formulaire avec validation) et score.
2. Calculateur d'intérêts composés, avec ses tests.
3. API de cours, cache local et simulation sur ETF ou action.
4. Leçons et simulations sauvegardées.
