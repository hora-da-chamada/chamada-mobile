import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:chamada_ufam/core/network/api_config.dart';
import 'package:chamada_ufam/models/sessao_chamada_model.dart';

class SessaoChamadaService {
  Future<List<SessaoChamada>> listarSessoesAtivas(String? token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/sessoes/ativas');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)); // Limite de 10 segundos

      if (response.statusCode == 200) {
        try {
          final List<dynamic> body = jsonDecode(response.body);
          return body.map((item) => SessaoChamada.fromJson(item)).toList();
        } catch (e) {
          throw Exception('Erro ao processar os dados recebidos do servidor.');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('SESSAO_EXPIRADA');
      } else {
        throw Exception('Erro ao carregar sessões (Código: ${response.statusCode}).');
      }
    } on TimeoutException {
      throw Exception('O servidor demorou muito a responder. Verifique a sua ligação à internet.');
    } catch (e) {
      rethrow;
    }
  }
}