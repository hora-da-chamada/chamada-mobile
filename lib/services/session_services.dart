import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chamada_ufam/models/usuario_model.dart';

class SessionService {
  static const String _userKey = 'logged_user';

  // Instância configurada para usar encriptação nativa do hardware
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Criptografa e salva o usuário e o token JWT
  Future<void> saveUser(Usuario usuario) async {
    final userJson = jsonEncode(usuario.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  // Descriptografa e recupera os dados do usuário
  Future<Usuario?> getUser() async {
    final userString = await _storage.read(key: _userKey);
    if (userString == null) return null;
    return Usuario.fromJson(jsonDecode(userString));
  }

  // Remove o token do cofre de chaves (Logout)
  Future<void> clearSession() async {
    await _storage.delete(key: _userKey);
  }
}   