/// « Bonjour » en journée, « Bonsoir » à partir de 18 h et pendant la nuit.
String greetingFor(DateTime now) {
  final hour = now.hour;
  return (hour >= 18 || hour < 5) ? 'Bonsoir' : 'Bonjour';
}

/// Heure au format 24 h, par exemple « 09:05 ».
String formatTime(DateTime time) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
}

/// Date au format français, par exemple « 06/10/2016 ».
String formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}

/// Montant avec deux décimales, une virgule et des espaces entre les
/// milliers, par exemple « 12 345,67 € ».
String formatPrice(double value, String currency) {
  final digits = value.abs().toStringAsFixed(2).split('.');
  // Une espace insécable avant chaque groupe de trois chiffres.
  final grouped = digits[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => '\u00A0',
  );
  final amount = '${value < 0 ? '-' : ''}$grouped,${digits[1]}';
  return currency.isEmpty ? amount : '$amount\u00A0$currency';
}

/// Variation en pourcentage, signée, par exemple « +12,3 % » ou « -4,0 % ».
String formatChange(double ratio) {
  return '${ratio >= 0 ? '+' : ''}${formatPercent(ratio)}';
}

/// Pourcentage sans signe, par exemple « 18,2 % ».
String formatPercent(double ratio) {
  final percent = (ratio * 100).toStringAsFixed(1).replaceAll('.', ',');
  return '$percent\u00A0%';
}
