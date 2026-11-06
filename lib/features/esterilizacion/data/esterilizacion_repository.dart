// lib/features/esterilizacion/data/esterilizacion_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campana_model.dart';

class EsterilizacionRepository {
  static final _supabase = Supabase.instance.client;

  static Future<List<CampanaModel>> getCampanas(String tipo) async {
    try {
      final response = await _supabase
          .from('campanas_bienestar')
          .select()
          .eq('tipo', tipo) // Filtra por 'esterilizacion' o 'desparasitacion'
          .order('created_at', ascending: false);

      return (response as List)
          .map((campana) => CampanaModel.fromJson(campana))
          .toList();
    } catch (e) {
      print('Error al obtener las campañas: $e');
      return [];
    }
  }
}