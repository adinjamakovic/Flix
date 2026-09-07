import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistory {
  static const int maxEntries = 5;

  static const String _keyPrefix = "previousSearches";

  static String get _key {
    final int? userId = AuthProvider.currentUserId;

    return userId == null ? _keyPrefix : "$_keyPrefix.$userId";
  }

  /// Newest first, without duplicates, capped at [maxEntries].
  static List<String> withEntry(List<String> current, String value) {
    final String title = value.trim();
    if (title.isEmpty) return current;

    final List<String> entries = List<String>.from(current)
      ..removeWhere((entry) => entry.toLowerCase() == title.toLowerCase())
      ..insert(0, title);

    if (entries.length > maxEntries) {
      entries.removeRange(maxEntries, entries.length);
    }

    return entries;
  }

  // Storage is a best-effort convenience: a platform without it, or a read that
  // fails, leaves the screen with an empty history rather than an error state.
  static Future<List<String>> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      return prefs.getStringList(_key) ?? <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  static Future<void> save(List<String> entries) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(_key, entries);
    } catch (_) {}
  }
}
