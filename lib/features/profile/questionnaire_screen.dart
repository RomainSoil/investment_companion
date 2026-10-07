import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/questionnaire.dart';
import '../../state/app_controller.dart';

/// Questionnaire de profil investisseur : une réponse par question, puis le
/// profil correspondant au score est enregistré.
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  /// Réponse choisie pour chaque question (position dans la liste des
  /// réponses), `null` tant que la question est sans réponse.
  final List<int?> _choices = List.filled(profileQuestionnaire.length, null);

  bool get _isComplete => !_choices.contains(null);

  void _submit() {
    var score = 0;
    for (var i = 0; i < profileQuestionnaire.length; i++) {
      score += profileQuestionnaire[i].answers[_choices[i]!].points;
    }
    final profile = profileForScore(score);

    context.read<AppController>().setProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Score $score / 10 : profil ${profile.label.toLowerCase()}.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votre profil investisseur')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final (i, question) in profileQuestionnaire.indexed)
            _QuestionBlock(
              number: i + 1,
              question: question,
              choice: _choices[i],
              onChanged: (choice) => setState(() => _choices[i] = choice),
            ),
          FilledButton(
            onPressed: _isComplete ? _submit : null,
            child: const Text('Voir mon profil'),
          ),
        ],
      ),
    );
  }
}

/// Une question et ses réponses ; une seule réponse peut être choisie.
class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.number,
    required this.question,
    required this.choice,
    required this.onChanged,
  });

  final int number;
  final Question question;

  /// Position de la réponse choisie, `null` si aucune.
  final int? choice;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ${question.text}', style: AppTextStyles.label),
          RadioGroup<int>(
            groupValue: choice,
            onChanged: onChanged,
            child: Column(
              children: [
                for (final (index, answer) in question.answers.indexed)
                  RadioListTile<int>(
                    value: index,
                    contentPadding: EdgeInsets.zero,
                    title: Text(answer.label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
