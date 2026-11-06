// lib/features/educacion/data/educacion_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evento_model.dart';

class EducacionRepository {
  static final _supabase = Supabase.instance.client;

  // Consulta todas las imagenes de los carruseles
  static Future<List<String>> getImagenesCarrusel() async {
    try {
      final response = await Supabase.instance.client
          .from('imagenes_carrusel') // Tu nombre real de la tabla
          .select('imagen_url')
          .order('orden', ascending: true); // Ordena según el número que le pongas

      return (response as List).map((e) => e['imagen_url'] as String).toList();
    } catch (e) {
      print('Error cargando carrusel: $e');
      return []; 
    }
  }

  // Consulta todos los eventos, ordenados por fecha de creación
  static Future<List<EventoModel>> getEventos(bool esPasado) async {
    try {
      final response = await _supabase
          .from('educacion_sensibilizacion')
          .select()
          .eq('es_pasado', esPasado)
          .order('creado_en', ascending: false);

      return (response as List<dynamic>)
          .map((json) => EventoModel.fromMap(json))
          .toList();
    } catch (e) {
      print('⚠️ Error al cargar eventos: $e');
      return [];
    }
  }
}