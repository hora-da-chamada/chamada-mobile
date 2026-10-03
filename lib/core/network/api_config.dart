import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Altere para 'true' quando for gerar o APK/App Bundle final
  static const bool isProduction = false;

  static String get baseUrl {
    if (isProduction) {
      // OBRIGATÓRIO: Substituir pelo domínio real da UFAM com HTTPS
      return 'https://api.chamada.ufam.edu.br/api'; 
    }
    
    // Ambiente de Desenvolvimento
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }
}