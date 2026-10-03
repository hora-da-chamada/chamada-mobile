import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:chamada_ufam/core/network/api_config.dart';
import 'package:chamada_ufam/models/usuario_model.dart';

class UsuarioService {
  Future<Usuario> login(String email, String senha) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),

      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return Usuario.fromJson(data);
        } catch (e) {
          throw Exception('Resposta inválida do servidor ao fazer login.');
        }
      } else {
        String mensagemErro = 'Falha ao autenticar (Código: ${response.statusCode}).';
        try {
          final errorData = jsonDecode(response.body);
          mensagemErro = errorData['message'] ?? mensagemErro;
        } catch (_) {}
        throw Exception(mensagemErro);
      }
    } on TimeoutException {
      throw Exception('O servidor demorou muito a responder. Verifique a sua ligação.');
    } catch (e) {
      rethrow;
    }
  }
}