import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Champ numérique positif ; accepte la virgule comme séparateur décimal.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.suffix,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String suffix;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    // Pas de « .0 » pour un nombre entier : on affiche « 100 » et non
    // « 100.0 ».
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString().replaceAll('.', ',');

    return TextFormField(
      initialValue: text,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      // Un champ vide compte pour 0 ; une saisie incomplète (« 1,2, ») est
      // ignorée en attendant la suite.
      onChanged: (input) {
        final parsed =
            input.isEmpty ? 0.0 : double.tryParse(input.replaceAll(',', '.'));
        if (parsed != null) {
          onChanged(parsed);
        }
      },
    );
  }
}
