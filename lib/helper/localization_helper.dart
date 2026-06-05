import 'package:get/get.dart';

/// Translates a UI label key or API message. Avoids showing raw snake_case keys.
String trLabel(String? raw, {String? fallback}) {
  if (raw == null || raw.isEmpty) return fallback ?? '';

  final input = raw.trim();

  for (final key in _translationKeyCandidates(input)) {
    final translated = key.tr;
    if (translated != key) return translated;
  }

  if (_looksLikeSnakeCaseKey(input)) {
    return _humanizeSnakeCase(input);
  }

  return fallback ?? input;
}

/// @deprecated Use [trLabel].
String localizeMessage(String? raw) => trLabel(raw);

List<String> _translationKeyCandidates(String input) {
  final lower = input.toLowerCase();
  final snake = lower
      .replaceAll(RegExp(r'[/\\s:.]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  return {
    input,
    lower,
    snake,
    input.replaceAll('/', '_'),
  }.where((k) => k.isNotEmpty).toList();
}

bool _looksLikeSnakeCaseKey(String s) =>
    s.contains('_') && !s.contains(' ') && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s);

String _humanizeSnakeCase(String s) {
  return s
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) {
        if (part.length == 1) return part.toUpperCase();
        return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
      })
      .join(' ');
}
