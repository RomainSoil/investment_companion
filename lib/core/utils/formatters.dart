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

/// Montant avec deux décimales et une virgule, par exemple « 28,47 USD ».
String formatPrice(double value, String currency) {
  final amount = value.toStringAsFixed(2).replaceAll('.', ',');
  return currency.isEmpty ? amount : '$amount $currency';
}

/// Variation en pourcentage, signée, par exemple « +12,3 % » ou « -4,0 % ».
String formatChange(double ratio) {
  final percent = (ratio * 100).toStringAsFixed(1).replaceAll('.', ',');
  return '${ratio >= 0 ? '+' : ''}$percent %';
}
