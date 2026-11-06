// lib/features/censo/data/censo_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/censo_model.dart';

class CensoRepository {
  // Inicializamos la conexión
  static final _supabase = Supabase.instance.client;

  static Future<void> registrarMascota(CensoModel censo) async {
    try {
      // Inserción directa en la tabla con todos los datos
      await _supabase.from('censo_mascotas').insert(censo.toMap());
      print('✅ Registro exitoso en censo_mascotas');
    } catch (e) {
      print('⚠️ Error al registrar en censo_mascotas: $e');
      throw Exception('Fallo al guardar en la base de datos');
    }
  }
}