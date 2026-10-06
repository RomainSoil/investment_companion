# Investment Companion

**Le compagnon du débutant en investissement.** Une application mobile Flutter
pour connaître son profil d'investisseur, simuler sans risque à partir de
cours réels et apprendre les bases, même hors connexion.

Projet réalisé par **Romain Soil** et **Camille Delot** dans le cadre du module
Compilation et Développement d'Applications Mobiles (FISA Informatique 5e
année, INSA Hauts-de-France).

> Application pédagogique : elle ne permet aucune transaction réelle et ne se
> connecte à aucune banque ni à aucun courtier.

## Pourquoi cette application

Quand on débute, on entend parler d'ETF, d'actions ou de PEA sans savoir par
où commencer : le vocabulaire est opaque, on a peur de perdre de l'argent et
on se projette mal sur plusieurs années. Nous avons voulu une application qui
fait découvrir ces notions en manipulant des données réelles plutôt qu'en
lisant un cours.

## Fonctionnalités

| Fonctionnalité | État |
| --- | --- |
| Écran de bienvenue au premier lancement, sans compte | Fait |
| Accueil : profil, état de la connexion, conseil du jour, accès rapides | Fait |
| Navigation à cinq onglets | Fait |
| Historique des cours sur 10 ans de 25 actifs, gardé sur le téléphone | Fait |
| Questionnaire de profil investisseur et actifs conseillés selon le risque | Fait |
| Calculateur d'intérêts composés (hors connexion) | Fait |
| Simulation « Et si j'avais investi… ? » sur un ETF ou une action | Fait |
| Leçons courtes avec quiz (ETF ou action, PEA / PEL / compte-titres…) | À venir |
| Simulations sauvegardées (« Mes simulations ») | Fait |
| Paramètres : devise d'affichage et taux de change dollar / euro | Fait |
| Actifs favoris | À venir |

## Installation

Prérequis : Flutter avec Dart 3.5 ou plus récent.

```bash
git clone <adresse-du-dépôt>
cd investment_companion
flutter pub get
cp env.example.json env.json   # puis y mettre sa clé Twelve Data
flutter run --dart-define-from-file=env.json
```

Les cours viennent de l'API [Twelve Data](https://twelvedata.com) (offre
gratuite : 8 appels par minute, 800 par jour, places américaines
uniquement). La clé se place dans `env.json`, ignoré par git. Sous Android
Studio, ajouter `--dart-define-from-file=env.json` dans *Additional run args*
de la configuration de lancement.

Un historique n'est téléchargé qu'à la première ouverture de l'actif, puis
relu depuis la base SQLite du téléphone (`lib/data/price_database.dart`).
Sous Windows, la compilation avec des plugins demande d'activer le mode
développeur (`start ms-settings:developers`).

Vérifications :

```bash
flutter analyze
flutter test
```

## Auteurs

Romain Soil et Camille Delot.