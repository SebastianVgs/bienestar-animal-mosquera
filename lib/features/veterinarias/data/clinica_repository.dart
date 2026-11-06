// lib/features/clinicas/data/clinica_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clinica_model.dart';

class ClinicaRepository {
  static final _supabase = Supabase.instance.client;

  static Future<List<ClinicaModel>> getClinicas() async {
    try {
      final response = await _supabase
          .from('clinicas_veterinarias')
          .select()
          .order('creado_en', ascending: true);

      return (response as List)
          .map((data) => ClinicaModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error al cargar las clínicas desde Supabase: $e');
      return []; // Si falla, devuelve una lista vacía para no romper el mapa
    }
  }
}