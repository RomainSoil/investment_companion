import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/asset.dart';
import '../../domain/investor_profile.dart';
import '../../state/app_controller.dart';
import 'asset_detail_screen.dart';
import 'asset_tile.dart';

/// Liste des actifs proposés : ceux conseillés pour le profil de
/// l'utilisateur en premier, puis tous les actifs par famille.
///
/// Aucun cours n'est téléchargé ici : l'appel à l'API n'a lieu qu'à
/// l'ouverture d'un actif (voir [AssetDetailScreen]).
class AssetListScreen extends StatelessWidget {
  const AssetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select<AppController, InvestorProfileType?>(
      (app) => app.profile,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un actif')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          if (profile != null) ...[
            _SectionTitle('Conseillés pour le profil ${profile.label}'),
            for (final asset in profile.advisedAssets) AssetTile(asset: asset),
          ],
          for (final category in AssetCategory.values) ...[
            _SectionTitle(category.label),
            for (final asset in assetCatalog)
              if (asset.category == category) AssetTile(asset: asset),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(text.toUpperCase(), style: AppTextStyles.overline),
    );
  }
}
