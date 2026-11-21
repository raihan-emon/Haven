import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());

class ApiKeyNotifier extends StateNotifier<String> {
  final SharedPreferences _p;
  ApiKeyNotifier(this._p) : super(_p.getString('api_key') ?? '');

  Future<void> set(String key) async {
    state = key.trim();
    await _p.setString('api_key', state);
  }
}

final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String>(
    (ref) => ApiKeyNotifier(ref.read(prefsProvider)));
