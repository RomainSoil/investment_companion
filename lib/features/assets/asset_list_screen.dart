import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/asset.dart';
import 'asset_detail_screen.dart';

/// Liste des actifs proposés, regroupés par famille.
///
/// Aucun cours n'est téléchargé ici : l'appel à l'API n'a lieu qu'à
/// l'ouverture d'un actif (voir [AssetDetailScreen]).
class AssetListScreen extends StatelessWidget {
  const AssetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un actif')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final category in AssetCategory.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                category.label.toUpperCase(),
                style: AppTextStyles.overline,
              ),
            ),
            for (final asset in assetCatalog)
              if (asset.category == category)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(asset.name, style: AppTextStyles.label),
                  subtitle: Text(
                    '${asset.symbol} · ${asset.description}',
                    style: AppTextStyles.caption,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AssetDetailScreen(asset: asset),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
