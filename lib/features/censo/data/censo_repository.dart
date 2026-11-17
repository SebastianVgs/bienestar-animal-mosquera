// lib/features/censo/data/censo_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/censo_model.dart';

class CensoRepository {
  static final _supabase = Supabase.instance.client;

  static Future<void> registrarMascota(CensoModel censo) async {
    try {
      await _supabase.from('censo_mascotas').insert(censo.toMap());
    } catch (e) {
      throw Exception('⚠️ Fallo al guardar en la base de datos: $e');
    }
  }

  static Future<List<CensoModel>> obtenerMascotasCensadas() async {
    try {
      final response = await _supabase
          .from('censo_mascotas')
          .select()
          .order('fecha_registro', ascending: false);

      return (response as List<dynamic>)
          .map((json) => CensoModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> actualizarMascota(CensoModel censo) async {
    try {
      await _supabase.from('censo_mascotas').update({
        'especie': censo.especie,
        'nombre_mascota': censo.nombreMascota,
        'raza': censo.raza,
        'edad': censo.edad,
        'unidad_edad': censo.unidadEdad,
        'sexo': censo.sexo,
        'nombre_propietario': censo.nombrePropietario,
        'documento_propietario': censo.documentoPropietario,
        'telefono': censo.telefono,
        'direccion': censo.direccion,
      }).eq('id', censo.id);
    } catch (e) {
      throw Exception('⚠️ Fallo al actualizar la mascota: $e');
    }
  }
}