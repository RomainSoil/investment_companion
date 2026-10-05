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
