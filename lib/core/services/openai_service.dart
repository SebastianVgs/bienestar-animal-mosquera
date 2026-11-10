
import 'dart:convert';
 
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
 
class OpenAIService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
 
  /// Analiza un reporte (texto + imagen) y devuelve un Map con:
  /// - 'gravedad': "Baja" | "Media" | "Alta" | "Desconocida"
  /// - 'resumen': resumen técnico corto
  static Future<Map<String, dynamic>> analizarReporte(
    String descripcion,
    String imagenUrl,
  ) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
 
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key de OpenAI no encontrada');
    }
 
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
 
    // El Prompt: Instrucciones estrictas para la IA (Ahora condicionado contra spam)
    final prompt = '''
    Eres un analista experto en bienestar animal trabajando para la Alcaldía de Mosquera.
    Tu tarea es analizar el reporte de un ciudadano y la fotografía adjunta.
    
    REGLA DE ORO: Si la descripción y la imagen NO tienen absolutamente nada que ver con animales o con un caso de bienestar animal, debes rechazarlo.
    
    Debes devolver ÚNICAMENTE un objeto JSON válido con estas dos claves:
    1. "gravedad": Clasifica el caso en "Baja", "Media", "Alta" (Alta es riesgo de muerte o abuso extremo). Si el reporte es spam o no tiene relación con animales, pon "Rechazado".
    2. "resumen": Un resumen técnico, objetivo y corto (máximo 20 palabras) para las autoridades. Si fue rechazado, escribe "Reporte no pertinente a bienestar animal".
    
    Descripción del ciudadano: $descripcion
    ''';
 
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      // Obligamos a que responda en JSON puro
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': imagenUrl,
                // 'low' ahorra tokens y dinero, suficiente para clasificar
                'detail': 'low',
              },
            },
          ],
        },
      ],
      'max_tokens': 150,
    });
 
    try {
      final response = await http
          .post(Uri.parse(_apiUrl), headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
 
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final String iaContent =
            jsonResponse['choices'][0]['message']['content'] as String;
 
        final decoded = jsonDecode(iaContent);
        return Map<String, dynamic>.from(decoded as Map);
      } else {
        debugPrint('Error OpenAI (${response.statusCode}): ${response.body}');
        return {
          'gravedad': 'Desconocida',
          'resumen': 'Error al analizar con IA',
        };
      }
    } catch (e) {
      debugPrint('Error de conexión con OpenAI: $e');
      return {
        'gravedad': 'Desconocida',
        'resumen': 'Error de conexión',
      };
    }
  }
}