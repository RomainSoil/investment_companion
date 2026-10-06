import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/status_badge.dart';
import '../../domain/asset.dart';
import 'asset_detail_screen.dart';

/// Ligne d'un actif : nom, description, niveau de risque. Ouvre sa fiche.
class AssetTile extends StatelessWidget {
  const AssetTile({super.key, required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(asset.name, style: AppTextStyles.label),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${asset.symbol} · ${asset.description}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 6),
            StatusBadge(
              label: 'Risque ${asset.risk.label.toLowerCase()}',
              tone: switch (asset.risk) {
                RiskLevel.low => BadgeTone.positive,
                RiskLevel.medium => BadgeTone.info,
                RiskLevel.high => BadgeTone.warning,
              },
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AssetDetailScreen(asset: asset),
        ),
      ),
    );
  }
}
