import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:chamada_ufam/core/network/api_config.dart';

class PresencaService {
  Future<void> registrarPresenca(int sessaoId, String? pin, String? token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/presencas');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessaoId': sessaoId,
          'codigoAcesso': pin,
        }),
      ).timeout(const Duration(seconds: 10)); // Limite de 10 segundos

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('SESSAO_EXPIRADA');
      } else if (response.statusCode != 200 && response.statusCode != 201) {
        String mensagemErro = 'Falha ao registar presença.';
        try {
          final errorData = jsonDecode(response.body);
          mensagemErro = errorData['message'] ?? mensagemErro;
        } catch (_) {} 
        throw Exception(mensagemErro);
      }
    } on TimeoutException {
      throw Exception('O servidor demorou muito a responder. Tente novamente.');
    } catch (e) {
      rethrow;
    }
  }
}