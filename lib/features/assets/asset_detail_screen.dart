import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/price_repository.dart';
import '../../domain/asset.dart';
import '../../domain/currency.dart';
import '../../domain/price_history.dart';
import '../../domain/savings_simulation.dart';
import '../../state/settings_controller.dart';
import 'price_chart.dart';
import 'what_if_section.dart';

/// Fiche d'un actif : historique des cours sur 10 ans, puis simulation
/// « Et si j'avais investi ? » sur ces cours.
///
/// L'historique vient de la base s'il a déjà été téléchargé, sinon de l'API
/// (voir [PriceRepository]).
///
/// Avec [initialPlan] (simulation enregistrée rouverte), la simulation est
/// préremplie et l'écran défile jusqu'à elle.
class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({super.key, required this.asset, this.initialPlan});

  final Asset asset;
  final SavingsPlan? initialPlan;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late Future<PriceHistory> _history;
  late SavingsPlan _plan = widget.initialPlan ?? const SavingsPlan();

  /// Repère la simulation, pour faire défiler l'écran jusqu'à elle.
  final _whatIfKey = GlobalKey();
  late bool _scrollToWhatIf = widget.initialPlan != null;

  // Chargement lancé une seule fois, et non dans `build` : une reconstruction
  // de l'écran ne relance pas l'appel.
  @override
  void initState() {
    super.initState();
    _history = _load();
  }

  Future<PriceHistory> _load() {
    return context.read<PriceRepository>().dailyHistory(widget.asset.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.asset.name)),
      body: FutureBuilder<PriceHistory>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorMessage(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _history = _load()),
            );
          }
          final history = snapshot.data;
          if (history == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_scrollToWhatIf) {
            // Une seule fois, une fois l'historique affiché.
            _scrollToWhatIf = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final target = _whatIfKey.currentContext;
              if (target != null) {
                Scrollable.ensureVisible(
                  target,
                  duration: const Duration(milliseconds: 400),
                );
              }
            });
          }
          return _HistoryView(
            asset: widget.asset,
            history: history,
            whatIfKey: _whatIfKey,
            plan: _plan,
            onPlanChanged: (plan) => setState(() => _plan = plan),
          );
        },
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.asset,
    required this.history,
    required this.whatIfKey,
    required this.plan,
    required this.onPlanChanged,
  });

  final Asset asset;
  final PriceHistory history;
  final GlobalKey whatIfKey;
  final SavingsPlan plan;
  final ValueChanged<SavingsPlan> onPlanChanged;

  @override
  Widget build(BuildContext context) {
    final points = history.points;
    if (points.isEmpty) {
      return const Center(child: Text('Aucun cours disponible.'));
    }

    final first = points.first;
    final last = points.last;
    final change = last.close / first.close - 1;

    // Cours convertis dans la devise choisie dans les paramètres ; une devise
    // que l'application ne gère pas est affichée telle quelle.
    final settings = context.watch<SettingsController>().currency;
    final source = Currency.fromCode(history.currency);
    final isConverted = source != null && source != settings.display;
    String price(double amount) {
      return source == null
          ? formatPrice(amount, history.currency)
          : formatPrice(
              settings.convert(amount, source),
              settings.display.symbol,
            );
    }

    // Pas de ListView : son contenu n'est construit qu'à l'approche de
    // l'écran, et la simulation doit exister pour que l'on défile jusqu'à elle.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${asset.symbol} · ${history.exchange}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            price(last.close),
            style: AppTextStyles.title,
          ),
          Text(
            '${formatChange(change)} depuis le ${formatDate(first.date)}',
            style: AppTextStyles.label.copyWith(
              color: change >= 0 ? AppColors.primary : AppColors.danger,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: PriceChart(points: points)),
          const SizedBox(height: 20),
          _InfoRow('Premier cours', price(first.close)),
          _InfoRow('Dernier cours', price(last.close)),
          _InfoRow('Période',
              '${formatDate(first.date)} – ${formatDate(last.date)}'),
          _InfoRow('Séances', '${points.length}'),
          const SizedBox(height: 16),
          Text(
            [
              'Données Twelve Data, enregistrées sur le téléphone le '
                  '${formatDate(history.fetchedAt)}.',
              if (isConverted)
                'Cours convertis au taux fixe de 1\u00A0\$ = '
                    '${formatPrice(settings.usdToEur, '€')}, modifiable dans les '
                    'paramètres.',
            ].join(' '),
            style: AppTextStyles.caption,
          ),
          const Divider(height: 48),
          WhatIfSection(
            key: whatIfKey,
            assetName: asset.name,
            history: history,
            plan: plan,
            onPlanChanged: onPlanChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          const SizedBox(width: 12),
          // Une valeur longue (la période) passe à la ligne au lieu de
          // déborder de l'écran.
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 38, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
