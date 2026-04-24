class PriceUtils {
  static int parseToCents(String text) {
    final normalized = text
    .replaceAll(',', '.')
    .replaceAll(RegExp(r'\.$'), '') 
    .trim();
    final value = double.tryParse(normalized);
    if (value == null) return 0;
    return (value * 100).round();
  }

  static String formatFromCents(int cents) {
    return (cents / 100).toStringAsFixed(2);
  }

  static bool isValid(String text) {
    return parseToCents(text) > 0;
  }
}