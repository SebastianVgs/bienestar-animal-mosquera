// lib/features/voluntariado/data/voluntariado_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
// Importación corregida apuntando a voluntariado_model.dart
import '../models/voluntariado_model.dart'; 

class VoluntariadoRepository {
  static final _supabase = Supabase.instance.client;

  static Future<void> enviarPostulacion(VoluntariadoModel postulacion) async {
    try {
      await _supabase.from('hogares_paso').insert(postulacion.toMap());
      print('✅ Postulación a hogar de paso enviada exitosamente');
    } catch (e) {
      print('⚠️ Error al guardar la postulación: $e');
      throw Exception('Fallo al conectar con la base de datos');
    }
  }
}