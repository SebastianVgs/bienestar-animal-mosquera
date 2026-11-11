// lib/features/admin/data/admin_reportes_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReportesRepository {
  static final _supabase = Supabase.instance.client;

  // Obtener reportes en tiempo real
  static Stream<List<Map<String, dynamic>>> obtenerReportesStream() {
    return _supabase
        .from('reportes_maltrato')
        .stream(primaryKey: ['id'])
        .order('creado_en', ascending: false);
  }

  // Actualizar el estado de un reporte
  static Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _supabase
        .from('reportes_maltrato')
        .update({'estado': nuevoEstado})
        .eq('id', id);
  }
}