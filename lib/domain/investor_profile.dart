/// Les trois profils d'investisseur attribués par le questionnaire.
enum InvestorProfileType {
  prudent('Prudent'),
  equilibre('Équilibré'),
  dynamique('Dynamique');

  const InvestorProfileType(this.label);

  /// Nom affiché à l'utilisateur.
  final String label;

  /// Retrouve un profil à partir de la valeur enregistrée sur le téléphone
  /// (le `name` de l'énumération). Renvoie `null` si la valeur est absente
  /// ou inconnue.
  static InvestorProfileType? fromStorage(String? value) {
    for (final type in InvestorProfileType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return null;
  }
}
