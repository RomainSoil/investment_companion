import 'package:flutter/material.dart';

/// Ouvre [screen] par-dessus l'écran actuel, avec un bouton retour.
Future<void> openScreen(BuildContext context, Widget screen) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}
