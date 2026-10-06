import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/number_field.dart';
import '../../domain/currency.dart';
import '../../state/settings_controller.dart';

/// Paramètres : devise d'affichage et taux de change dollar / euro.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text('Devise d’affichage', style: AppTextStyles.label),
          const SizedBox(height: 8),
          SegmentedButton<Currency>(
            segments: const [
              ButtonSegment(value: Currency.eur, label: Text('Euro (€)')),
              ButtonSegment(value: Currency.usd, label: Text('Dollar (\$)')),
            ],
            selected: {settings.currency.display},
            onSelectionChanged: (selection) =>
                settings.setDisplayCurrency(selection.single),
          ),
          const SizedBox(height: 24),
          const Text('Taux de change', style: AppTextStyles.label),
          const SizedBox(height: 8),
          NumberField(
            label: 'Valeur de 1 \$ en euros',
            suffix: '€',
            value: settings.currency.usdToEur,
            onChanged: settings.setUsdToEur,
          ),
          const SizedBox(height: 8),
          const Text(
            'Les actifs proposés sont cotés en dollars : ce taux sert à '
            'afficher leurs cours en euros. Il reste fixe, quelle que soit la '
            'date du cours.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
