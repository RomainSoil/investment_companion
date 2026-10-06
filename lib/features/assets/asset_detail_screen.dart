import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/price_repository.dart';
import '../../domain/asset.dart';
import '../../domain/price_history.dart';
import 'price_chart.dart';

/// Fiche d'un actif : historique des cours sur 10 ans.
///
/// L'historique vient de la base s'il a déjà été téléchargé, sinon de l'API
/// (voir [PriceRepository]).
class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({super.key, required this.asset});

  final Asset asset;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late Future<PriceHistory> _history;

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
          return _HistoryView(asset: widget.asset, history: history);
        },
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.asset, required this.history});

  final Asset asset;
  final PriceHistory history;

  @override
  Widget build(BuildContext context) {
    final points = history.points;
    if (points.isEmpty) {
      return const Center(child: Text('Aucun cours disponible.'));
    }

    final first = points.first;
    final last = points.last;
    final change = last.close / first.close - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          '${asset.symbol} · ${history.exchange}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          formatPrice(last.close, history.currency),
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
        _InfoRow('Premier cours', formatPrice(first.close, history.currency)),
        _InfoRow('Dernier cours', formatPrice(last.close, history.currency)),
        _InfoRow(
            'Période', '${formatDate(first.date)} – ${formatDate(last.date)}'),
        _InfoRow('Séances', '${points.length}'),
        const SizedBox(height: 16),
        Text(
          'Données Twelve Data, enregistrées sur le téléphone le '
          '${formatDate(history.fetchedAt)}.',
          style: AppTextStyles.caption,
        ),
      ],
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
          Text(value, style: AppTextStyles.body),
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
