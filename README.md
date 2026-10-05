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
| Questionnaire de profil investisseur et score expliqué | À venir |
| Calculateur d'intérêts composés (hors connexion) | À venir |
| Simulation « Et si j'avais investi… ? » sur un ETF ou une action | À venir |
| Leçons courtes avec quiz (ETF ou action, PEA / PEL / compte-titres…) | À venir |
| Simulations sauvegardées et actifs favoris | À venir |

## Installation

Prérequis : Flutter avec Dart 3.5 ou plus récent.

```bash
git clone <adresse-du-dépôt>
cd investment_companion
flutter pub get
flutter run
```

Vérifications :

```bash
flutter analyze
flutter test
```

## Auteurs

Romain Soil et Camille Delot.