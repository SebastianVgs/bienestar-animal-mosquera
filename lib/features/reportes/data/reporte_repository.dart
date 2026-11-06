import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bienestar_animal_app/features/reportes/models/reporte_model.dart';
// Asegúrate de importar donde configuraste 'supabase'
// import '../../../../core/constants.dart'; 

class ReporteRepository {
  static final _supabase = Supabase.instance.client;

  static Future<void> crearReporte({
    required String description,
    required String address,
    required double? latitude,
    required double? longitude,
    required List<String> localEvidencePaths,
  }) async {
    try {
      List<String> imageUrls = [];

      // 1. Subir cada foto al Storage de Supabase
      for (String path in localEvidencePaths) {
        final file = File(path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
        
        await _supabase.storage.from('imagenes_reportes').upload(fileName, file);
        
        final imageUrl = _supabase.storage.from('imagenes_reportes').getPublicUrl(fileName);
        imageUrls.add(imageUrl);
      }

      // 2. Guardar el reporte en la tabla (sin IA por ahora)
      await _supabase.from('reportes_maltrato').insert({
        'descripcion': description,
        'direccion': address,
        'latitud': latitude,
        'longitud': longitude,
        'evidencia_url': imageUrls.isNotEmpty ? imageUrls.first : '',
        'nivel_urgencia': 'EN_EVALUACION', // Por defecto hasta que haya IA
        'estado': 'RECIBIDO',
        'creado_en': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      print('Error al guardar reporte en Supabase: $e');
      throw Exception('Error de base de datos');
    }
  }

  // Función para leer los reportes
  // Función para leer los reportes
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
      // ESTO ES CLAVE: Te dirá el error exacto en tu consola (VS Code)
      print('🔥 ERROR CRÍTICO al obtener los reportes: $e'); 
      return []; 
    }
  }
}