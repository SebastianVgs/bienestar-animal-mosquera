import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bienestar_animal_app/features/reportes/models/reporte_model.dart';

// 1. IMPORTANTE: Agrega la importación de tu nuevo servicio de IA
// Ajusta esta ruta si guardaste openai_service.dart en otra carpeta
import 'package:bienestar_animal_app/core/services/openai_service.dart';

class ReporteRepository {
  static final _supabase = Supabase.instance.client;

  static Future<void> crearReporte({
    required String description,
    required String address,
    required String telefono,
    required double? latitude,
    required double? longitude,
    required List<String> localEvidencePaths,
  }) async {
    try {
      print('--- INICIANDO PROCESO DE REPORTE ---');
      List<String> imageUrls = [];
      String primeraImagenUrl = '';

      // 1. Subir foto
      for (String path in localEvidencePaths) {
        final file = File(path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
        await _supabase.storage.from('imagenes_reportes').upload(fileName, file);
        final imageUrl = _supabase.storage.from('imagenes_reportes').getPublicUrl(fileName);
        imageUrls.add(imageUrl);
      }

      if (imageUrls.isNotEmpty) {
        primeraImagenUrl = imageUrls.first;
      }

      // 2. Llamada a OpenAI
      Map<String, dynamic> analisisIA = {'gravedad': 'Desconocida', 'resumen': 'Sin análisis'};
      if (description.isNotEmpty && primeraImagenUrl.isNotEmpty) {
        analisisIA = await OpenAIService.analizarReporte(description, primeraImagenUrl);
      }

      // 3. Insertar en Base de Datos
      final datosAInsertar = {
        'descripcion': description,
        'direccion': address,
        'telefono_contacto': telefono, // NUEVO DATO A INSERTAR
        'latitud': latitude ?? 4.7093,
        'longitud': longitude ?? -74.2278,
        'evidencia_url': primeraImagenUrl,
        'estado': 'RECIBIDO',
        'nivel_urgencia': analisisIA['gravedad'],
        'ia_gravedad': analisisIA['gravedad'],
        'ia_resumen': analisisIA['resumen']
      };

      await _supabase.from('reportes_maltrato').insert(datosAInsertar);
      print('--- REPORTE CREADO EXITOSAMENTE ---');
      
    } catch (e) {
      print('🔥 ERROR CRÍTICO AL GUARDAR REPORTE: $e');
      throw Exception('Error de base de datos: $e');
    }
  }

  // Función para leer los reportes (Sin cambios)
  static Future<List<ReporteModel>> getMisReportes() async {
    try {
      print('Iniciando consulta a Supabase...');
      // 1. Hacemos la consulta a Supabase
      final response = await _supabase
          .from('reportes_maltrato')
          .select()
          .order('creado_en', ascending: false);
          
      print('Respuesta recibida: $response'); // Verifica qué llega

      // 2. Convertimos los datos crudos
      final List<ReporteModel> reportes = (response as List<dynamic>)
          .map((json) {
            print('Mapeando registro: $json'); // Si falla aquí, es el fromJson
            return ReporteModel.fromJson(json);
          })
          .toList();

      return reportes;
    } catch (e) {
      print('🔥 ERROR CRÍTICO al obtener los reportes: $e'); 
      return []; 
    }
  }
}